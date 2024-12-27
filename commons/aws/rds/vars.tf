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

variable "create_rds_reader" {
  description = "Whether RDS read replicas are needed (true/false)."
}

variable "db_cluster_parameter_group_parameters" {
  description = "Custom DB cluster parameter group parameters."
  default     = []
}

variable "create_db_cluster_parameter_group" {
  description = "Create a custom DB cluster parameter group (true/false)."
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the RDS cluster (true/false)."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The KMS key ID for encryption."
  default     = "aws/"
}

variable "enable_auto_minor_version_upgrade" {
  description = "Enable auto minor version upgrade (true/false)."
  type        = bool
  default     = false
}

variable "preferred_backup_window" {
  description = "Preferred backup window for the RDS cluster."
  default     = "07:00-09:00"
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  default     = 7
}

variable "enable_performance_insights" {
  description = "Enable performance insights (true/false)."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data."
  type        = number
  default     = 7
}

variable "ca_cert_identifier" {
  description = "CA certificate identifier for the RDS cluster."
  default     = "rds-ca-2019"
}

variable "enable_rds_event_notifications" {
  type    = bool
  default = true
}

variable "publicly_accessible" {
  default = false
}
variable "enabled_cloudwatch_logs_exports" {
  default = ["slowquery", "audit", "error"]
}

variable "db_parameter_group_parameters" {
  type    = list(map(string))
  default = []
}

variable "reader_instance_type" {
  type = string
}

variable "ingress_whitelist" {
  description = "List of SGs or CIDRs to Whitelist to RDS SG"
  type        = list(string)
}

variable "eks_sg" {
  type    = string
  default = null
}

variable "whitelist_eks" {
  type    = bool
  default = false
}

variable "resources_key_arn" {
  description = "KMS CMK Arn for SSE Encryption"
  type        = string
}

variable "snapshot_identifier" {
  description = "Identifier for snapshot to restore"
  type        = string
  default     = null
}

variable "primary_cluster_arn" {
  description = "ARN of primary RDS cluster for creating Global cluster"
  type=string
  default = null
}

variable "create_global_cluster" {
  description = "True if global rds cluster is to be created"
  type=bool
  default = false
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "tags" {}