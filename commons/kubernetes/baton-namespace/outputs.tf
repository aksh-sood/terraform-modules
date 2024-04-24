output "activemq_credentials" {
  value = var.enable_activemq ? {
    namespace = var.namespace
    url       = module.activemq[0].url[0]
    username  = var.activemq_username
    password  = module.activemq[0].password
  } : null
  sensitive = true
}