#aws eks addons
variable "eks_addons" {
  type    = list(string)
  default = ["vpc-cni", "coredns", "kube-proxy", "aws-ebs-csi-driver", "aws-efs-csi-driver", "aws-mountpoint-s3-csi-driver"]
}

variable "eks_ingress_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to EKS (ingress)"
  type        = list(string)
  default     = []
}

variable "eks_public_access" {
  description = "EKS Control Plane Public Access. Default true"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  type = string
}

variable "node_groups" {

  default = [{
    name = "node1"

    instance_types = ["m5.large"]

    min_size                   = 1
    max_size                   = 1
    additional_security_groups = []

    tags = {}
    }

  ]
}

variable "mount_point_s3_bucket_name" {
  type    = string
  default = null
}

variable "eks_public_access_ips" {
  description = "CIDRs to allow public access to eks"
  type        = list(string)
}

variable "alb_ingress_whitelist" {
  description = "CIDRs to allow ingress on 80 and 443 for alb"
  type        = list(string)
}

variable "region" {}
variable "cluster_version" {}
variable "cluster_name" {}
variable "eks_tags" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "public_subnet_ids" {}
variable "private_subnet_cidrs" {}
variable "kms_key_arn" {}
variable "eks_node_groups" {}
variable "siem_storage_s3_bucket" {}
variable "azs" {}
variable "private_subnets_cidr" {}
variable "additional_eks_addons" {}
variable "enable_cluster_autoscaler" {}
variable "vpn_security_group" {}
variable "enable_client_vpn" {}
