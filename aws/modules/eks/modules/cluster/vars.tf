variable "vpc_id" {
  description = "VPC id in which cluster is to be provisioned"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "eks_ingress_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to EKS (ingress)"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "list of private subnets where cluster and ndoes will reside"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "list of public subnets where cluster and ndoes will reside"
  type        = list(string)
}

variable "eks_public_access_ips" {
  description = "CIDRs to allow public access to eks"
  type        = list(string)
}

variable "kms_key_arn" {}
variable "elb_security_group" {}
variable "cluster_role_arn" {}
variable "eks_tags" {}

#Common Variables
variable "region" {}
variable "cluster_version" {}
variable "cluster_name" {}
variable "eks_public_access" {
  description = "EKS Control Plane Public Access. Default true"
  type        = bool
  default     = false
}
variable "secrets_key_bucket_name" {}
