output "activemq_url" {
  value = module.activemq.url
}

output "activemq_password" {
  value     = module.activemq.password
  sensitive = true
}

output "activemq_username" {
  value     = var.activemq_username
  sensitive = true
}