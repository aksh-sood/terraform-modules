variable "region" {}
variable "vendor" {}
variable "environment" {}
variable "opensearch_password" {}
variable "opensearch_username" {}
variable "opensearch_endpoint" {}
variable "s3_bucket_for_curator" {}
variable "curator_iam_user_arn" {}
variable "curator_iam_role_arn" {}
variable "curator_iam_user_access_key" {}
variable "curator_iam_user_secret_key" {}
variable "curator_image_tag" {
  default = "1.1.7"
}
