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


data "template_file" "config_map" {
  template = file("${path.module}/config.yaml")
  vars = {
    OPENSEARCH_USERNAME      = var.opensearch_username
    OPENSEARCH_PASSWORD      = var.opensearch_password
    OPENSEARCH_ENDPOINT      = var.opensearch_endpoint
    DELETE_OLD_INDICES_COUNT = var.delete_indices_from_es
  }

}

data "template_file" "cronjob" {
  template = file("${path.module}/cronjob.yaml")
  vars = {
    DOCKER_IMAGE = var.docker_image_arn
    CONFIG_MAP   = kubernetes_config_map.curator_config.metadata[0].name
  }
}

resource "aws_s3_bucket" "curator" {
  count  = var.create_s3_bucket_for_curator ? 1 : 0
  bucket = "osttra-${var.environment}-elastisearch-backup"
}

resource "aws_iam_role" "curator" {
  name = "TheSnapShotRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "es.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "ESS3SnapShotPolicy"
    policy = templatefile("${path.module}/ESS3SnapShotPolicy.json", {
      S3_BUCKET = var.create_s3_bucket_for_curator ? aws_s3_bucket.curator[0].id : "osttra-${var.environment}-elastisearch-backup"
    })
  }
}

resource "aws_iam_user" "curator" {
  name = "User-Curator"
}

resource "aws_iam_policy" "iam_full_access_policy" {
  name        = "IAMFullAccessPolicy"
  description = "Policy that grants full access to IAM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "iam:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.curator.name
  policy_arn = aws_iam_policy.iam_full_access_policy.arn
}

# Create Access Key for IAM User
resource "aws_iam_access_key" "iam_user_access_key" {
  user = aws_iam_user.curator.name
}


# Create a role mapping
resource "opensearch_roles_mapping" "curator" {
  role_name   = "manage_snapshots"
  description = "Adding the Curator role"
  users = [
    "${aws_iam_user.curator.arn}"
  ]

}

data "external" "register_es_repository" {
  program = ["python3", "${path.module}/register_repository.py"]
  query = {
    bucket         = var.create_s3_bucket_for_curator ? aws_s3_bucket.curator[0].id : "osttra-${var.environment}-elastisearch-backup"
    region         = var.region
    es_url         = "https://${var.opensearch_endpoint}/"
    es_user        = var.opensearch_username
    es_password    = var.opensearch_password
    role_arn       = aws_iam_role.curator.arn
    aws_access_key = aws_iam_access_key.iam_user_access_key.id
    aws_secret_key = aws_iam_access_key.iam_user_access_key.secret

  }
}

# ConfigMap for Curator
resource "kubernetes_config_map" "curator_config" {
  metadata {
    name      = "curator-config"
    namespace = "logging"
  }
  data = {
    config = data.template_file.config_map.rendered
  }
}

# CronJob for Curator
resource "kubectl_manifest" "curator" {
  provider  = kubectl.this
  yaml_body = data.template_file.cronjob.rendered
}


