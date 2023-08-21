variable "vpc_id" {
  description = "VPC id in which cluster is to be provisioned"
  type        = string
}

variable "private_subnet_ids" {
  description = "list of private subnets where cluster and ndoes will reside"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "list of public subnets where cluster and ndoes will reside"
  type        = list(string)
}

variable "kms_key_arn" {}
variable "cluster_role_arn" {}
variable "eks_tags" {}

#Common Variables
variable "region" {}
variable "cluster_version" {}
variable "cluster_name" {}
