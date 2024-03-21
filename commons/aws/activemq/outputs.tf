output "url" {
  description = "URL of the activeMQ instance created inside the EKS VPC"
  value       = aws_mq_broker.activemq.instances.0.endpoints[0]

}

output "password" {
  description = "Password for ActiveMQ"
  value       = random_password.activemq_password.result
  sensitive   = true

}

output "username" {
  description = "Username for ActiveMQ"
  value       = var.username
  sensitive   = true
}
