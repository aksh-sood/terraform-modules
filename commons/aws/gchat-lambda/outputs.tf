output "url" {
  description = "The lambda URL to which alertmanager webhook payload needs to be send for forwarding to gchat"
  value       = aws_lambda_function_url.this.function_url
}