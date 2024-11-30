variable "primary_crr_rds_config" {
  description = "Parameters to configure RDS cluster"
  type = object({
    backup_retention_period         = number
    eks_security_group              = string
    kms_key_id                      = string
    subnet_ids                      = list(string)
    deletion_protection             = optional(bool, true)
    parameter_group_family          = optional(string, "aurora-mysql8.0")
    engine_version                  = optional(string, "8.0.mysql_aurora.3.05.2")
    instance_type                   = optional(string, "db.t4g.large")
    enabled_cloudwatch_logs_exports = optional(list(string), ["slowquery", "audit", "error"])
    db_parameter_group_parameters = optional(list(map(string)), [
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
  })
  default = null
}

variable "cost_tags" {
  type    = map(string)
  default = {}
}

variable "primary_central_vpc_id" {
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
variable "primary_rds_security_group_id" {}
variable "dr_rds_cluster_arn" {}
variable "db_parameter_group_name" {}