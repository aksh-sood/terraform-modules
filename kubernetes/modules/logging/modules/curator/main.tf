# Configure the OpenSearch provider
terraform {
  required_version = ">= 0.13"
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3.0"
    }
    kubectl = {
      source                = "gavinbunney/kubectl"
      version               = ">= 1.7.0"
      configuration_aliases = [kubectl.this]
    }
  }
}

provider "opensearch" {
  url                = "https://${var.opensearch_endpoint}:443"
  aws_region         = var.region
  username           = var.opensearch_username
  password           = var.opensearch_password
  healthcheck        = false
  sign_aws_requests  = false
  opensearch_version = 2.11
}


# Create a role mapping
resource "opensearch_roles_mapping" "curator" {
  role_name   = "manage_snapshots"
  description = "Adding the Curator role"
  users = [
    var.curator_iam_user_arn
  ]
}

resource "kubernetes_job" "repository_registration" {
  metadata {
    name      = "curator-snapshot-registration"
    namespace = "logging"
  }
  spec {
    template {
      metadata {
        name = "curator-snapshot-registration"
      }
      spec {
        container {
          name  = "curator-snapshot-registration"
          image = "python:3.9"


          command = ["/bin/sh", "-c", "pip install requests && pip install requests-aws4auth && python /scripts/register_repository.py"]
          env {
            name  = "OPENSEARCH_USERNAME"
            value = var.opensearch_username
          }
          env {
            name  = "OPENSEARCH_PASSWORD"
            value = var.opensearch_password
          }
          env {
            name  = "OPENSEARCH_ENDPOINT"
            value = var.opensearch_endpoint
          }
          env {
            name  = "REGION"
            value = var.region
          }
          env {
            name  = "S3_BUCKET"
            value = var.s3_bucket_for_curator
          }
          env {
            name  = "IAM_ROLE"
            value = var.curator_iam_role_arn
          }
          env {
            name  = "ACCESS_KEY"
            value = var.curator_iam_user_access_key
          }
          env {
            name  = "SECRET_KEY"
            value = var.curator_iam_user_secret_key
          }
          volume_mount {
            name       = "script-volume"
            mount_path = "/scripts"
          }

        }

        restart_policy = "Never"

        volume {
          name = "script-volume"

          config_map {
            name = kubernetes_config_map.repository_registration.metadata[0].name
          }
        }
      }
    }

    backoff_limit = 4
  }

  depends_on = [opensearch_roles_mapping.curator]
}

resource "kubernetes_config_map" "repository_registration" {
  metadata {
    name      = "curator-snapshot-registration"
    namespace = "logging"
  }

  data = {
    "register_repository.py" = file("${path.module}/configs/register_repository.py")
  }
}

resource "kubectl_manifest" "curator_config" {
  provider = kubectl.this
  yaml_body = templatefile("${path.module}/configs/curator-config.yaml", {
    opensearch_endpoint = var.opensearch_endpoint
    opensearch_username = var.opensearch_username
    opensearch_password = var.opensearch_password

  })

}

resource "kubectl_manifest" "curator-cronjob" {
  provider = kubectl.this
  yaml_body = templatefile("${path.module}/configs/cronjob.yaml", {
    docker_image = "381491919895.dkr.ecr.us-west-2.amazonaws.com/baton/utilities/curator"
    tag          = var.curator_image_tag
  })
}


