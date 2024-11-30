output "endpoint" {
  value = aws_opensearch_domain.domain.endpoint
}

output "password" {
  value = random_password.password.result
}

output "username" {
  value = var.master_username
}

output "curator_iam_role_arn" {
  value = aws_iam_role.curator.arn
}

output "curator_iam_user_arn" {
  value = aws_iam_user.curator.arn
}

output "curator_iam_user_access_key" {
  value     = aws_iam_access_key.iam_user_access_key.id
  sensitive = true
}

output "curator_iam_user_secret_key" {
  value     = aws_iam_access_key.iam_user_access_key.secret
  sensitive = true
}
