variable "lambda_role_policies" {
  type = set(string)
  default = [
    "AmazonS3FullAccess",
    "AmazonKinesisFullAccess",
    "AWSLambda_FullAccess",
    "AmazonSQSFullAccess",
    "AmazonEC2FullAccess",
    "AWSXRayDaemonWriteAccess",
    "service-role/AWSLambdaKinesisExecutionRole"
  ]
}

variable "name" {}
variable "region" {}