variable "stream_arn" {
  type = string
  default = null
}
variable "sqs_arn" {
  type = string
  default = null
}

variable "name" {}
variable "package_key" {}
variable "handler" {}
variable "environment_variables" {}
variable "subnet_ids" {}
variable "lambda_role_arn" {}
variable "vpc_id" {}
variable "lambda_packages_s3_bucket" {}
variable "tags" {}