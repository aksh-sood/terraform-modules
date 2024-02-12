variable "snapshot_retention_limit" {
  description = "The number of days for which ElastiCache retains automatic snapshots before deleting them."
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "The daily time range (in UTC) during which ElastiCache takes daily snapshots."
  type        = string
  default     = "03:00-04:00"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t2.micro"
}

variable "engine_version" {
  description = "Engine version for redis elasticache"
  type        = string
  default     = "5.0.5"
}

variable "region" {}
variable "vpc_id" {}
variable "environment" {}
variable "subnet_ids" {}
variable "parameter_group_name" {}
variable "whitelist_security_groups" {}
variable "tags" {}