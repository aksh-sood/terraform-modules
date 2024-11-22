variable "region" {
  type    = string
  default = "us-east-1"
}

variable "dr_region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  description = "Name of the fx admin environment to be setup"
  type        = string
  default     = "test"
}

variable "is_dr" {
  type    = bool
  default = false
}

variable "is_prod" {
  type    = bool
  default = false
}

variable "setup_dr" {
  type    = bool
  default = false
}

variable "dr_kms_key_arn" {
  description = "KMS key ARN in DR for FX ADMIN resources"
  type        = string
  default     = null
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

variable "dr_tags" {
  description = "Customer Cost and Environment tags for all the DR resources.Merged with `cost_tags` attribute"
  type        = map(string)
  default     = {}
}


variable "activemq_engine_version" {
  type    = string
  default = "5.18"
}

variable "activemq_instance_type" {
  type    = string
  default = "mq.m5.large"
}

variable "activemq_apply_immediately" {
  type    = bool
  default = true
}

variable "activemq_auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "activemq_publicly_accessible" {
  type    = bool
  default = false
}

variable "activemq_username" {
  type      = string
  sensitive = true
  default   = "admin"
}

variable "activemq_ingress_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to ActiveMQ (ingress)"
  type        = list(string)
  default     = []
}

variable "activemq_egress_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to ActiveMQ (egress)"
  type        = list(string)
  default     = []
}

variable "lambda_packages_s3_bucket" {
  description = "S3 bucket name with JAR packages for lambda functions"
  type        = string
  default     = "fx-dev-lambda-packages"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "domain_name" {
  description = "Domain Name registered in DNS service"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}\\.[a-zA-Z]{2,6}$", var.domain_name))
    error_message = "Domain name should be valid (e.g., example.com)"
  }
}

variable "import_directory_service_db" {
  description = "Whether to import data into directory service database"
  type        = bool
  default     = true
}

variable "directory_service_data_s3_bucket_name" {
  description = "name of the s3 bucket where directory service database dump is stored"
  type        = string
  default     = null
}

variable "directory_service_data_s3_bucket_region" {
  description = "region of the s3 bucket where directory service database dump is stored"
  type        = string
  default     = "us-east-1"
}

variable "directory_service_data_s3_bucket_path" {
  description = "prefix of the s3 bucket where directory service database dump is stored"
  type        = string
  default     = null
}




variable "vendor" {
  type = string
}

variable "vpc_id" {}
variable "eks_security_group" {}