module "filebeat" {
  source           = "./modules/filebeat"
  opensearch_endpoint      = var.opensearch_endpoint
  opensearch_username      = var.opensearch_username
  opensearch_password      = var.opensearch_password
  environment_name = var.environment_name
}
