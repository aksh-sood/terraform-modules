variable "kinesis_policies" {
  type = set(string)
  default = [
    "AmazonKinesisAnalyticsFullAccess",
    "AmazonKinesisFirehoseFullAccess",
    "AmazonKinesisFullAccess",
    "AmazonS3FullAccess",
    "AWSLambda_FullAccess"
  ]
}

variable "environment" {}
variable "matched_trades_arn" {}
variable "normalized_trades_arn" {}
variable "tags" {}
variable "region" {}