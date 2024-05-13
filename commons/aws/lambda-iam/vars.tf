variable "lambda_role_policies" {
  type = set(string)
  default = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonKinesisFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
  ]
}

variable "name" {}
variable "region" {}
variable "s3_bucket_arn" {}
variable "sqs_queue_arn" {}