resource "aws_sqs_queue" "this" {
  count                      = 1
  name                       = "${var.environment}-${var.name}"
  visibility_timeout_seconds = 305
  tags                       = var.tags
}
