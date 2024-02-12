variable "region" {
  type    = string
  default = "us-west-2"
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

variable "rds_mysql_version" {
  description = "mysql version for rds aurora"
  type        = string
  default     = "5.7"
}

variable "rds_instance_type" {
  description = "RDS Instance Type"
  type        = string
  default     = "db.t4g.large"
}

variable "rds_master_username" {
  description = "Master Username for RDS"
  type        = string
  default     = "master"
}

variable "create_rds_reader" {
  description = "Enable reader for RDS"
  type        = bool
  default     = false
}

variable "rds_parameter_group_family" {
  description = "Parameter group Family name. Will be applied to both parameter group and db cluster parameter group"
  type        = string
  default     = "aurora-mysql5.7"
}

variable "rds_enable_performance_insights" {
  description = "Enable RDS Performance Insights"
  type        = bool
  default     = false
}
variable "rds_performance_insights_retention_period" {
  description = "Retention period for performance Insights"
  type        = number
  default     = 7
}

variable "rds_enable_event_notifications" {
  description = "Enable RDS Event Notifications. Notifications through SNS"
  type        = bool
  default     = true
}

variable "rds_reader_instance_type" {
  description = "Instance Type for RDS Reader"
  type        = string
  default     = "db.t4g.large"
}

variable "rds_ingress_whitelist" {
  description = "List Containing SGs or CIDRs to be whitelisted by RDS SG"
  type        = list(string)
  default     = []
}

variable "rds_enable_deletion_protection" {
  description = "Enable Cluster deletion protection"
  type        = bool
  default     = false
}

variable "rds_enable_auto_minor_version_upgrade" {
  description = "Enable Auto Minor Version Upgrade"
  type        = bool
  default     = false
}

variable "rds_db_cluster_parameter_group_parameters" {
  description = "Cluster Parameter Group Parameters"
  type        = list(map(string))
  default     = []
}

variable "rds_preferred_backup_window" {
  description = "Preffered RDS Backup Window. Time in UTC"
  type        = string
  default     = "07:00-09:00"
}

variable "rds_publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default false"
  type        = bool
  default     = false
}

variable "rds_db_parameter_group_parameters" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default = [
    {
      name         = "long_query_time"
      value        = "10"
      apply_method = "immediate"
    }
  ]
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql"
  type        = list(string)
  default     = ["slowquery", "audit", "error"]
}

variable "rds_ca_cert_identifier" {
  description = "	The identifier of the CA certificate for the DB instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "rds_backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "activemq_engine_version" {
  type    = string
  default = "5.15.16"
}

variable "activemq_storage_type" {
  type    = string
  default = "efs"
}

variable "activemq_host_instance_type" {
  type    = string
  default = "mq.t2.micro"
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "activemq_publicly_accessible" {
  type    = bool
  default = true
}

variable "activemq_username" {
  type      = string
  sensitive = true
  default   = "admin"
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
  default = "batonsystems.com"
}

variable "vpc_id" {}
variable "eks_security_group" {}
variable "environment" {}
variable "kms_key_arn" {}
variable "vendor" {}
variable "baton_application_namespaces" {}