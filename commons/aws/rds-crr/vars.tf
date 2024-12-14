variable "name" {
  description = "Name of RDS DR cluster resources"
  type        = string
}

variable "region" {
  description = "Region ID where Primary cluster is provisioned"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID of the DR region"
  type        = string
}

variable "dr_eks_security_group" {
  description = "Security group ID for EKS in DR region"
  type        = string
}

variable "whitelist_eks" {
  type    = bool
  default = true
}

variable "subnet_ids" {
  description = "List of subnets for the RDS DR cluster"
}

variable "tags" {
  description = "Tags for the RDS DR resources"
  type        = map(string)
}

variable "kms_key_id" {
  description = "KMS key ARN present in DR region"
  type        = string
}

variable "primary_rds_cluster_arn" {
  description = "ARN of the RDS Cluster that is being replicated"
  type        = string
}


variable "deletion_protection" {
  type    = bool
  default = false
}

variable "parameter_group_family" {
  description = "This value will be used by both db parameter group and db cluster parameter group"
}

variable "db_cluster_parameter_group_parameters" {
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default = [
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
  ]
}

variable "engine" {
  type    = string
  default = "aurora-mysql"
}

variable "engine_version" {
  type    = string
  default = "5.7.mysql_aurora.2.11.5"
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  default     = 7
}

variable "instance_class" {
  description = "Instance size of the replica"
  default     = "db.t4g.large"
}

variable "enabled_cloudwatch_logs_exports" {
  default = ["slowquery", "audit", "error"]
}


variable "security_group" {
  description = "Security group ID of Primary site used before switchover to DR"
  type        = string
  default     = null
}

variable "create_sg" {
  type    = bool
  default = true
}

variable "create_db_subnet_group" {
  type    = bool
  default = true
}

variable "create_rds_cluster_parameter_group" {
  type    = bool
  default = true
}

variable "rds_cluster_parameter_group_name" {
  type    = string
  default = null
}

variable "db_subnet_group_id" {
  type    = string
  default = null
}

variable "db_parameter_group_name" {
  type    = string
  default = null
}