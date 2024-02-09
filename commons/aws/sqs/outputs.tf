output "arn" {
    value = aws_sqs_queue.this[0].arn
}