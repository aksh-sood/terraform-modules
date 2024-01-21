module "filebeat" {
  source           = "./modules/filebeat"
  os_endpoint      = var.os_endpoint
  os_username      = var.os_username
  os_password      = var.os_password
  environment_name = var.environment_name
}
