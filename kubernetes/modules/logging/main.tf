terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    configuration_aliases = [kubectl.this] }
  }
}

module "filebeat" {
  source = "./modules/filebeat"

  opensearch_endpoint = var.opensearch_endpoint
  opensearch_username = var.opensearch_username
  opensearch_password = var.opensearch_password
  environment         = var.environment
  domain_name         = var.domain_name

  providers = {
    kubectl.this = kubectl.this
  }
}

module "curator" {
  source                       = "./modules/curator"
  opensearch_endpoint          = var.opensearch_endpoint
  opensearch_username          = var.opensearch_username
  opensearch_password          = var.opensearch_password
  create_s3_bucket_for_curator = var.create_s3_bucket_for_curator
  docker_image_arn             = var.docker_image_arn
  delete_indices_from_es       = var.delete_indices_from_es
  environment                  = var.environment
  region                       = var.region
  providers = {
    kubectl.this = kubectl.this
  }

}


