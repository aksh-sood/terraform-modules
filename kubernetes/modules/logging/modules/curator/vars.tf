variable "docker_image_arn" {
    type = string
    default = "381491919895.dkr.ecr.us-west-2.amazonaws.com/baton/utilities/curator:1.1.7"
}

variable "region" {}
variable "vendor" {}
variable "environment" {}
variable "create_s3_bucket_for_curator" {}
variable "opensearch_endpoint" {}
variable "opensearch_username" {}
variable "opensearch_password" {}
variable "delete_indices_from_es" {}