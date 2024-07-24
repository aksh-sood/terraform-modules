variable "lambda_role_policies" {
  type = set(string)
  default = [
    "service-role/AWSLambdaKinesisExecutionRole",
    "service-role/AWSLambdaRole",
    "service-role/AWSLambdaSQSQueueExecutionRole",
    "service-role/AWSLambdaENIManagementAccess"
  ]
}

variable "name" {}
variable "region" {}
variable "s3_bucket_arn" {}
variable "sqs_queue_arn" {}
variable "matched_trades_stream_arn" {}
variable "normalized_trades_stream_arn" {}