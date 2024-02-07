#aws eks addons
variable "eks_addons" {
  type    = set(string)
  default = ["vpc-cni", "coredns", "kube-proxy", "aws-ebs-csi-driver"]
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
variable "azs" {}
variable "private_subnets_cidr" {}