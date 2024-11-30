
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

output "rabbitmq_broker" {
  value = aws_mq_broker.rabbitmq.broker_name
}

output "endpoint" {
  value = aws_mq_broker.rabbitmq.instances.0.endpoints.0
}

output "rabbitmq_sg" {
  value = aws_security_group.rabbitmq.id
}
