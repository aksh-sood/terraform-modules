output "security_group_id" {
  description = "Security group ID attached to the lambda functions"
  value       = aws_security_group.lambda.id
}