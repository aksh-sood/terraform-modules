//TODO: KMS key Encryption
resource "aws_kinesis_stream" "this" {
  name             = var.name
  shard_count      = 1
  retention_period = 24
  tags             = var.tags

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]
}
