output "activemq_url" {
  description = "URL of the activeMQ instance created inside the EKS VPC"
  value       = aws_mq_broker.activemq.instances.0.endpoints[0]

}

output "activemq_password" {
  description = "Password for ActiveMQ"
  value       = random_password.activemq_password.result
  sensitive   = true

}

output "activemq_username" {
  description = "Username for ActiveMQ"
  value       = var.activemq_username
  sensitive   = true
}
