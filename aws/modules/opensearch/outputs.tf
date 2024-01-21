output "domain_id" {
  value = aws_opensearch_domain.domain.domain_id
}

output "endpoint" {
  value = aws_opensearch_domain.domain.endpoint
}

output "password" {
  value = random_password.password.result
}

output "username" {
  value = "master"
}