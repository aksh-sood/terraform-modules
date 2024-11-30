terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    configuration_aliases = [kubectl.this] }
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

module "filebeat" {
  source = "./modules/filebeat"

  namespace           = kubernetes_namespace.logging.metadata[0].name
  opensearch_endpoint = var.opensearch_endpoint
  opensearch_username = var.opensearch_username
  opensearch_password = var.opensearch_password
  environment         = var.environment
  domain_name         = var.domain_name

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [var.dependency]
}

module "curator" {
  source = "./modules/curator"

  region                      = var.region
  environment                 = var.environment
  vendor                      = var.vendor
  opensearch_endpoint         = var.opensearch_endpoint
  opensearch_username         = var.opensearch_username
  opensearch_password         = var.opensearch_password
  curator_image_tag           = var.curator_image_tag
  s3_bucket_for_curator       = var.s3_bucket_for_curator
  curator_iam_user_arn        = var.curator_iam_user_arn
  curator_iam_role_arn        = var.curator_iam_role_arn
  curator_iam_user_access_key = var.curator_iam_user_access_key
  curator_iam_user_secret_key = var.curator_iam_user_secret_key

  providers = {
    kubectl.this = kubectl.this
  }
}
