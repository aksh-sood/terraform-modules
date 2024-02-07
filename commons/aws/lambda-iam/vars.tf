variable "lambda_role_policies" {
  type = set(string)
  default = [
    "AmazonS3FullAccess",
    "AmazonKinesisFullAccess",
    "AWSLambda_FullAccess",
    "AmazonSQSFullAccess",
    "AmazonEC2FullAccess",
    "service-role/AWSLambdaKinesisExecutionRole"
  ]
}

variable "environment" {}
variable "region" {}