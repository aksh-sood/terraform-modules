output "url" {
  description = "The lambda URL to which alertmanager webhook payload needs to be send for forwarding to gchat"
  value       = aws_lambda_function_url.this.function_url
}

output "lambda_arn" {
  description = "The lambda ARN to which the cloudwatch alerts will be forwarded to and inturn to gchat"
  value       = aws_lambda_function.this.arn
}

output "lambda_name" {
  description = "The lambda to which the cloudwatch alerts will be forwarded to and inturn to gchat"
  value       = aws_lambda_function.this.id
}
