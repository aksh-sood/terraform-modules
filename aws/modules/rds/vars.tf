variable "name" {
  description = "Name of RDS cluster."
}

variable "vpc_id" {
  description = "VPC ID where the RDS cluster will be deployed."
}

variable "subnets" {
  description = "List of subnets for the RDS cluster."
}

variable "mysql_version" {
  description = "The MySQL version for the RDS cluster."
}

variable "parameter_group_family" {
  description = "This value will be used by both db parameter group and db cluster parameter group"
}

variable "rds_instance_type" {
  description = "The instance type for the RDS cluster."
}

variable "master_username" {
  description = "Username for the RDS master user."
}

variable "rds_reader_needed" {
  description = "Whether RDS read replicas are needed (true/false)."
}

variable "db_cluster_parameter_group_parameters" {
  default     = []
  description = "Custom DB cluster parameter group parameters."
}

variable "create_db_cluster_parameter_group" {
  default     = true
  type        = bool
  description = "Create a custom DB cluster parameter group (true/false)."
}

variable "enable_deletion_protection" {
  default     = false
  type        = bool
  description = "Enable deletion protection for the RDS cluster (true/false)."
}

variable "kms_key_id" {
  default     = "aws/"
  description = "The KMS key ID for encryption."
}

variable "enable_auto_minor_version_upgrade" {
  default     = false
  type        = bool
  description = "Enable auto minor version upgrade (true/false)."
}

variable "preferred_backup_window" {
  default     = "07:00-09:00"
  description = "Preferred backup window for the RDS cluster."
}

variable "backup_retention_period" {
  default     = 7
  description = "Backup retention period in days."
}

variable "enable_performance_insights" {
  default     = false
  type        = bool
  description = "Enable performance insights (true/false)."
}

variable "performance_insights_retention_period" {
  default = 7
  type = number
  description = "Amount of time in days to retain Performance Insights data."
}

variable "ca_cert_identifier" {
  default     = "rds-ca-rsa2048-g1"
  description = "CA certificate identifier for the RDS cluster."
}

variable "enable_rds_event_notifications" {
  default = true
  type = bool
}

variable "publicly_accessible" {
  default = false
}
variable "enabled_cloudwatch_logs_exports" {
  default = ["slowquery", "audit", "error"]
}

variable "db_parameter_group_parameters" {
  default = []
  type = list(object({
    name = string
    value = string
    apply_method = string
  }))
}

variable "reader_instance_type" {
  type = string
}

variable "ingress_whitelist" {}
variable "cost_tags" {}
variable "eks_sg" {
  type = string
  default = null
}
variable "whitelist_eks" {
  type = bool
  default = false
}