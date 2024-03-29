resource "aws_secretsmanager_secret" "this" {
  name_prefix = var.name
  kms_key_id  = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secrets)
}