variable "efs_version" {
  type    = string
  default = "2.2.0"
}
variable "lbc_version" {
  type    = string
  default = "1.6.0"
}

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
variable "kms_key_arn" {}
variable "eks_node_groups" {}
variable "acm_certificate_arn" {}
variable "istio_version" {}