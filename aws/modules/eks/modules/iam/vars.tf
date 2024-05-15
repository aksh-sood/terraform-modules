#  EKS cluster variables
variable "cluster_policies" {
  description = "Policies for cluster"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}

#  EKS node variables

variable "node_policies" {
  description = "AWS Managed Policies for nodes"
  type        = list(string)
  default     = []
}

variable "grafana_policies" {
  description = "Policies for grafana cloudwatch role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]
}

variable "additional_node_policies" {
  description = "additional policies to attach to the eks node group"
  type        = list(string)
  default     = []
}

variable "additional_node_inline_policy" {
  description = "Additional inline Policy to attach to node IAM role"
  type        = string
  default     = null
}

variable "mount_point_s3_bucket_name" {}
variable "tags" {}
variable "cluster_name" {}
variable "region" {}