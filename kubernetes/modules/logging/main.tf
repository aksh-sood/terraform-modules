module "filebeat" {
  source = "./modules/filebeat"

  isito_dependency = var.isito_dependency

  opensearch_endpoint = var.opensearch_endpoint
  opensearch_username = var.opensearch_username
  opensearch_password = var.opensearch_password
  environment         = var.environment
  domain_name         = var.domain_name
}
