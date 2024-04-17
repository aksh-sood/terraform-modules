output "activemq_credentials" {
  value = var.enable_activemq ? {
    namespace = var.namespace
    url       = module.activemq[0].url
    username  = var.activemq_username
    password  = module.activemq[0].password
  } : null
}