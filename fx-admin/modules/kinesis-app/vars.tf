variable "kinesis_policies" {
  type = set(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonKinesisAnalyticsFullAccess",
    "arn:aws:iam::aws:policy/AmazonKinesisFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  ]
}

variable "name" {}
variable "matched_trades_arn" {}
variable "normalized_trades_arn" {}
variable "tags" {}
variable "region" {}