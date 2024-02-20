resource "aws_sqs_queue" "this" {
  name                       = var.name
  visibility_timeout_seconds = 305
  tags                       = var.tags
}
