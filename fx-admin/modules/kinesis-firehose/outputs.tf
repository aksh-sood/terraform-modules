output "failed_trml_firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.failed_trml_firehose_stream.arn
}

output "trm_delivery_firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.trm_delivery_firehose_stream.arn
}

output "firehose_role_arn" {
  value = aws_iam_role.firehose_role.arn
}