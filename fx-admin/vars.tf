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
  default     = "rds-ca-2019"
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
  default = true
}

variable "activemq_username" {
  type      = string
  sensitive = true
  default   = "admin"
}

variable "activemq_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to ActiveMQ"
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

variable "baton_application_namespaces" {

  description = "List of namespaces and services and there required attributes"
  type = list(object({
    namespace       = string
    customer        = string
    enable_activemq = optional(bool, false)
    docker_registry = optional(string, "150399859526.dkr.ecr.us-west-2.amazonaws.com")
    istio_injection = optional(bool, true)
    common_env      = optional(map(string), {})
    services = list(object({
      name             = string
      url_prefix       = string
      target_port      = number
      port             = optional(number, 8080)
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

  default = [
    {
      namespace       = "fx-baton-uat"
      customer        = "osttra"
      istio_injection = false
      services = [
        {
          name        = "directory-service"
          target_port = 8080
          url_prefix  = "/directory"
          image_tag   = "1.0.4"
        },
        {
          name        = "normalizer"
          target_port = 8080
          url_prefix  = "/normalizer"
          image_tag   = "2.0.13"
        },
        {
          name        = "notaryservice"
          target_port = 8080
          url_prefix  = "/notary"
          image_tag   = "2.0.4"
        },
        {
          name        = "swiftservice"
          target_port = 8080
          url_prefix  = "/swift"
          image_tag   = "2.0.2"
        }
      ]
    }
  ]
}

variable "rabbitmq_engine_version" {
  description = "Version of the RabbitMQ broker engine"
  type        = string
  default     = "3.11.20"
}

variable "rabbitmq_enable_cluster_mode" {
  description = "Enable RabbitMQ Cluster Mode. Default is `false`"
  type        = bool
  default     = false
}

variable "rabbitmq_instance_type" {
  description = "Broker's instance type"
  type        = string
  default     = "mq.t3.micro"
}

variable "rabbitmq_auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available. Default is `false`"
  type        = bool
  default     = false
}

variable "rabbitmq_username" {
  description = "Username of the user. Default is `master`"
  type        = string
  default     = "master"
}

variable "rabbitmq_apply_immediately" {
  description = "Specifies whether any broker modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = false
}

variable "rabbitmq_virtual_host" {
  description = "Name of the virtual host to create in rabbitmq"
  default     = "/nex_osttra"
}

variable "rabbitmq_exchange" {
  description = "Name of the exchange to configure in rabbitmq"
  default     = "trml_osttra"
}

variable "environment" {
  description = "Name of the fx admin environment to be setup"
  type        = string
  default     = "test"
}

variable "k8s_cluster_name" {
  description = "Name of the EKS cluster where applications should be deployed"
  type        = string
  default     = "test"
}

variable "create_dns_records" {
  default = false
}

variable "loadbalancer_url" {
  default = ""
}

variable "cloudflare_api_token" {
  description = "API token to access cloudflare"
  type        = string
}
variable "additional_secrets" {
  description = "additional map of secrets to be saved in secrets manager"
  default     = {}
}

variable "sftp_host" {
  description = "Host name for sftp"
  type        = string
}

variable "sftp_username" {
  description = "Username for sftp"
  type        = string
}

variable "sftp_password" {
  description = "Password for sftp"
  type        = string
}

variable "vpc_id" {}
variable "eks_security_group" {}
variable "kms_key_arn" {}
variable "vendor" {
  type = string
}