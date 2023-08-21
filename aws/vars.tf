variable "region" {
  description = "Region of aws provider to run on"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment for which the resources are being provisioned"
  type        = string
  default     = "test"
}

variable "vpc_cidr" {
  description = "cidr range for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cost_tags" {
  description = "Customer Cost and Environment tags for all the resources "
  type        = map(string)
  default = {
    env-type    = "test"
    customer    = "internal"
    cost-center = "overhead"
  }
}

variable "vpc_tags" {
  description = "tags for VPC and any related resources that do not have tags associated with them"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "tags for private subnets"
  type        = map(string)
  default     = {}
}

variable "az_count" {
  description = "List of az's code to create subnets in"
  type        = number
  validation {
    condition     = var.az_count > 0 || var.az_count < 6
    error_message = "number should be a greater than 0 and less than 6"
  }
  default = 3
}


variable "enable_nat_gateway" {
  description = "Enable single NAT Gateway for vpc"
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "cidr list of public subnets"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "private_subnet_cidrs" {
  description = "cidr list of private subnets"
  type        = list(string)
  default     = ["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]
}

# make sure that S3 bucket policies are configured properly to allow logs from diffrent sources like vpc and ELB
variable "siem_storage_s3_bucket" {
  description = "bucket id for alerts and logging"
  type        = string
  default     = "aes-siem-800161367015-log"
}

variable "acm_certificate_bucket" {
  description = "Bucket name of acm certificate data"
  type        = string
  default     = "baton-domain-certificates"
}

variable "acm_certificate" {
  description = "S3 path to ACM Domain key"
  type        = string
  default     = "batonsystems.com/cloudflare/batonsystems.com.key"
}

variable "acm_certificate_chain" {
  description = "S3 path to ACM certificate key"
  type        = string
  default     = "batonsystems.com/cloudflare/batonsystems.com.crt"
}

variable "acm_private_key" {
  description = "S3 path to ACM private key"
  type        = string
  default     = "batonsystems.com/cloudflare/origin_ca_rsa_root.pem"
}

variable "create_eks" {
  default = true
}

variable "cluster_version" {
  description = "eks cluster verison"
  type        = string
  default     = "1.27"
}

variable "eks_node_groups" {
  description = "configuration of eks managed nodes groups"
  type = object({
    additional_node_inline_policy = optional(string, null)
    additional_node_policies      = optional(list(string), null)
    volume_type                   = string
    volume_size                   = number
    node_groups = list(object({
      name                       = string
      instance_types             = list(string)
      min_size                   = number
      max_size                   = number
      additional_security_groups = optional(list(string), [])
      tags                       = optional(map(string), {})
    }))
  })

  default = {

    additional_node_inline_policy = null
    additional_node_policies      = null
    volume_type                   = "gp3"
    volume_size                   = 20

    node_groups = [{
      name = "node1"

      instance_types = ["m5.large"]

      min_size = 1
      max_size = 1

      additional_security_groups = []

      tags = {}
      }

    ]

  }
}
