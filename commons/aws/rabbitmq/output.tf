
output "password" {
  value     = random_password.rabbitmq_password.result
  sensitive = true
}

output "username" {
  value = var.username
}

output "console_url" {
  value = aws_mq_broker.rabbitmq.instances.0.console_url
}

output "endpoint" {
  value = aws_mq_broker.rabbitmq.instances.0.endpoints.0
}