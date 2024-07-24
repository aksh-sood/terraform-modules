//TODO: KMS key Encryption
resource "aws_kinesis_stream" "this" {
  name             = var.name
  shard_count      = 1
  retention_period = 24
  encryption_type  = "KMS"
  kms_key_id       = var.kms_key_arn
  tags             = var.tags

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}
