terraform {
  required_version = ">= 0.13"

  required_providers {
    # opensearch = {
    #   source  = "opensearch-project/opensearch"
    #   version = "2.3.0"
    #   configuration_aliases = [opensearch.this]
    # }
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

  depends_on = [ var.dependency ]
}

module "curator" {
  source                       = "./modules/curator"
  
  region                       = var.region
  vendor = var.vendor
  environment                  = var.environment
  opensearch_endpoint          = var.opensearch_endpoint
  opensearch_username          = var.opensearch_username
  opensearch_password          = var.opensearch_password
  delete_indices_from_es       = var.delete_indices_from_es
  create_s3_bucket_for_curator = var.create_s3_bucket_for_curator

  providers = {
    kubectl.this = kubectl.this
    # opensearch.this = opensearch.this
  }

}


