variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "tags" {}
variable "eks_security_group" {}
variable "whitelist_security_groups" {}
variable "rabbitmq_whitelist_ips" {}

variable "storage_type" {
  description = "For `engine_type` RabbitMQ, only ebs is supported"
  type        = string
  default     = "ebs"
}

variable "engine_version" {
  description = "Version of the RabbitMQ broker engine"
  type        = string
  default     = "3.11.20"
}

variable "enable_cluster_mode" {
  description = "Enable RabbitMQ Cluster Mode. Default is `false`"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Broker's instance type"
  type        = string
  default     = "mq.m5.large"
}

variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available. Default is `false`"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets. Default is `false`"
  type        = bool
  default     = false
}

variable "username" {
  description = "Username of the user. Default is `master`"
  type        = string
  default     = "master"
}

variable "apply_immediately" {
  description = "Specifies whether any broker modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = false
}
