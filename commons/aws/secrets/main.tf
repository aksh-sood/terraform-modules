resource "aws_secretsmanager_secret" "this" {
  name_prefix = var.name
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secrets)
}