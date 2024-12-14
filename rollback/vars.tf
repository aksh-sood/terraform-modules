variable "rds_config" {
  description = "parameters to configure RDS cluster"
  type = object({
    engine_version             = optional(string, "8.0.mysql_aurora.3.05.2")
    backup_retention_period    = number
    enable_deletion_protection = optional(bool, true)
    instance_type              = optional(string, "db.t4g.large")
    parameter_group_family     = optional(string, "aurora-mysql8.0")
    db_cluster_parameter_group_parameters = optional(list(map(string)), [
      {
        name         = "log_bin_trust_function_creators"
        value        = 1
        apply_method = "pending-reboot"
        }, {
        name         = "binlog_format"
        value        = "MIXED"
        apply_method = "pending-reboot"
        }, {
        name         = "long_query_time"
        value        = "10"
        apply_method = "immediate"
      }
    ])
    enabled_cloudwatch_logs_exports = optional(list(string), ["slowquery", "audit", "error"])
  })
  default = {
    backup_retention_period = 7
  }
}

variable "cost_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "primary_rds_cluster_parameter_group_name" {
  type = string
}

variable "primary_db_subnet_group_id" {
  type = string
}

variable "region" {}
variable "environment" {}
variable "kms_key_arn" {}
variable "eks_security_group" {}
variable "private_subnet_ids" {}
variable "secondary_rds_cluster_arn" {}
variable "primary_rds_security_group_id" {}
variable "db_parameter_group_name" {}