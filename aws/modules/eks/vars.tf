#aws eks addons
variable "eks_addons" {
  type    = list(string)
  default = ["vpc-cni", "coredns", "kube-proxy", "aws-ebs-csi-driver", "aws-efs-csi-driver","aws-mountpoint-s3-csi-driver"]
}

variable "eks_ingress_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to EKS (ingress)"
  type        = list(string)
  default     = []
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
  type = string
  default = null
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