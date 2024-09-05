variable "lambda_role_policies" {
  type = set(string)
  default = [
    "service-role/AWSLambdaKinesisExecutionRole",
    "service-role/AWSLambdaRole",
    "service-role/AWSLambdaSQSQueueExecutionRole",
    "service-role/AWSLambdaENIManagementAccess"
  ]
}

variable "streams_arn" {
  description = "List of stream ARNs for lambda to access"
  type        = list(string)
}

variable "name" {}
variable "region" {}
variable "s3_bucket_arn" {}
variable "sqs_queue_arn" {}
