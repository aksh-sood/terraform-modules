output "url_1" {
  description = "URL of the activeMQ instance created inside the EKS VPC"
  value       = aws_mq_broker.activemq.instances.0.endpoints[0]
}

output "url_2" {
  description = "URL of the activeMQ instance created inside the EKS VPC"
  value       = var.deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" ? aws_mq_broker.activemq.instances.1.endpoints[0] : aws_mq_broker.activemq.instances.0.endpoints[0]
}

output "username" {
  description = "Username for ActiveMQ"
  value       = var.username
  sensitive   = true
}

output "password" {
  description = "Password for ActiveMQ"
  value       = random_password.activemq_password[0].result
  sensitive   = true
}

output "replica_username" {
  description = "Username for ActiveMQ"
  value       = var.replica_username
  sensitive   = true
}

output "replica_password" {
  description = "Password for ActiveMQ"
  value       = random_password.activemq_password[1].result
  sensitive   = true
}

output "console_url_1" {
  description = "URL 1 of the activeMQ instance"
  value       = regex("https://([^:]+)", aws_mq_broker.activemq.instances.0.console_url)[0]
}

output "console_url_2" {
  description = "URL 2 of the activeMQ instance"
  value       = var.deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" ? regex("https://([^:]+)", aws_mq_broker.activemq.instances.1.console_url)[0] : regex("https://([^:]+)", aws_mq_broker.activemq.instances.0.console_url)[0]
}