resource "aws_sqs_queue" "this" {
  name                       = var.name
  visibility_timeout_seconds = 305
  sqs_managed_sse_enabled    = false
  tags                       = var.tags
}
