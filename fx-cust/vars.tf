variable "region" {
  type    = string
  default = "us-east-1"
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
  default     = true
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

variable "lambda_packages_s3_bucket" {
  description = "S3 bucket name with JAR packages for lambda functions"
  type        = string
  default     = "fx-dev-lambda-packages"
}

variable "additional_secrets" {
  description = "additional map of secrets to be saved in secrets manager"
  type        = map(any)
  default     = {}
}

variable "redis_parameter_group_name" {
  description = "Redis parameted group name"
  type        = string
  default     = "default.redis5.0"
}

variable "redis_engine_version" {
  description = "Engine version for redis elasticache"
  type        = string
  default     = "7.1.0"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t2.micro"
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

variable "create_dns_records" {
  default = false
}

variable "callback_prefix" {
  description = "callback prefix subdomain for cognito App Client Integerations"
  type        = list(string)
  default     = null
}

variable "logout_prefix" {
  description = "logout prefix subdomain for cognito App Client Integerations"
  type        = list(string)
  default     = null
}


variable "activemq_engine_version" {
  type    = string
  default = "5.15.16"
}

variable "activemq_storage_type" {
  type    = string
  default = "efs"
}

variable "activemq_instance_type" {
  type    = string
  default = "mq.t2.micro"
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

variable "baton_application_namespaces" {

  description = "List of namespaces and services and there required attributes"
  type = list(object({
    namespace       = string
    customer        = string
    docker_registry = optional(string, "150399859526.dkr.ecr.us-west-2.amazonaws.com")
    istio_injection = optional(bool, true)
    common_env      = optional(map(string), {})
    services = list(object({
      name             = string
      target_port      = number
      url_prefix       = string
      health_endpoint  = optional(string, "/health")
      subdomain_suffix = optional(string, "")
      env              = optional(map(string), {})
      image_tag        = optional(string, "latest")
      volumeMounts = optional(object({
        volumes = list(any)
        mounts = list(object({
          mountPath = string
          name      = string
          subPath   = string
        }))
        }),
        {
          volumes = []
          mounts  = []
      })
    }))
  }))
  default = []
}

variable "vpc_id" {}
variable "eks_security_group" {}
variable "eks_node_role_arn" {}
variable "eks_cluster_role_arn" {}
variable "environment" {}
variable "kms_key_arn" {}
variable "vendor" {}
variable "external_loadbalancer_url" {}
variable "cloudflare_api_token" {}