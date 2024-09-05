variable "region" {
  type    = string
  default = "us-east-1"
}

variable "dr_region" {
  type    = string
  default = "us-west-2"
}

variable "environment" {
  description = "Name of the fx admin environment to be setup"
  type        = string
  default     = "test"
}

variable "is_dr" {
  type    = bool
  default = false
}

variable "is_prod" {
  type    = bool
  default = false
}

variable "setup_dr" {
  type    = bool
  default = false
}

variable "dr_kms_key_arn" {
  description = "KMS key ARN in DR for FX ADMIN resources"
  type        = string
  default     = null
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

variable "dr_tags" {
  description = "Customer Cost and Environment tags for all the DR resources.Merged with `cost_tags` attribute"
  type        = map(string)
  default     = {}
}

variable "create_rds" {
  type    = bool
  default = true
}

variable "rds_config" {
  description = "parameters to configure RDS cluster"
  type = object({
    performance_insights_retention_period = number
    preferred_backup_window               = string
    backup_retention_period               = number
    enable_deletion_protection            = optional(bool, true)
    mysql_version                         = optional(string, "8.0")
    instance_type                         = optional(string, "db.t4g.large")
    master_username                       = optional(string, "master")
    parameter_group_family                = optional(string, "aurora-mysql8.0")
    enable_performance_insights           = optional(bool, true)
    enable_event_notifications            = optional(bool, false)
    reader_instance_type                  = optional(string, "db.t4g.large")
    ingress_whitelist                     = optional(list(string), [])
    enable_auto_minor_version_upgrade     = optional(bool, false)
    publicly_accessible                   = optional(bool, false)
    enabled_cloudwatch_logs_exports       = optional(list(string), ["slowquery", "audit", "error"])
    ca_cert_identifier                    = optional(string, "rds-ca-rsa2048-g1")
    snapshot_identifier                   = optional(string, null)
    create_rds_reader                     = optional(bool, false)
    apply_immediately                     = optional(bool, false)
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
    db_parameter_group_parameters = optional(list(map(string)), [
      {
        name         = "log_bin_trust_function_creators"
        value        = 1
        apply_method = "pending-reboot"
        }, {
        name         = "long_query_time"
        value        = "10"
        apply_method = "immediate"
      }
    ])
  })
  default = {
    performance_insights_retention_period = 7
    preferred_backup_window               = "07:00-09:00"
    backup_retention_period               = 7
  }
}

variable "crr_rds_config" {
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

variable "activemq_engine_version" {
  type    = string
  default = "5.18"
}

variable "activemq_instance_type" {
  type    = string
  default = "mq.m5.large"
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

variable "sftp_ingress_whitelist" {
  description = "List of IPv4 CIDR blocks to whitelist to SFTP HOST (ingress)"
  type        = list(string)
  default     = []
}

variable "sftp_ami_id" {
  type = string
}

variable "sftp_disable_api_stop" {
  type    = bool
  default = true
}

variable "sftp_disable_api_termination" {
  type    = bool
  default = true
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

variable "directory_service_data_s3_bucket_name" {
  description = "name of the s3 bucket where directory service database dump is stored"
  type        = string
  default     = null
}

variable "directory_service_data_s3_bucket_region" {
  description = "region of the s3 bucket where directory service database dump is stored"
  type        = string
  default     = "us-east-1"
}

variable "directory_service_data_s3_bucket_path" {
  description = "prefix of the s3 bucket where directory service database dump is stored"
  type        = string
  default     = null
}

variable "prod_namespace" {
  description = "Acts a validator for prod deployment to append custom commands to swift service"
  type        = string
  default     = "fx-baton-prod"
}

variable "baton_application_namespaces" {
  description = "List of namespaces and services and there required attributes"
  type = map(object({
    customer                 = string
    enable_activemq          = optional(bool, false)
    docker_registry          = optional(string, "381491919895.dkr.ecr.us-west-2.amazonaws.com")
    istio_injection          = optional(bool, true)
    common_env               = optional(map(string), {})
    env_config_map           = optional(map(any), {})
    env_config_map_file_path = optional(map(string), {})
    services = map(object({
      url_prefix           = string
      target_port          = number
      config_map           = optional(map(any), {})
      config_map_file_path = optional(map(string), {})
      replicas             = optional(number, 1)
      command              = optional(list(string), null)
      security_context     = optional(bool, true)
      port                 = optional(number, 8080)
      health_endpoint      = optional(string, "/health")
      subdomain_suffix     = optional(string, "")
      env                  = optional(map(string), {})
      image_tag            = optional(string, "latest")
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

  default = {
    "fx-baton-uat" = {
      customer        = "osttra"
      istio_injection = false
      services = {
        "directory-service" = {
          security_context = false
          target_port      = 8080
          url_prefix       = "/directory"
          image_tag        = "1.0.15"
        },
        "normalizer" = {
          security_context = false
          target_port      = 8080
          url_prefix       = "/normalizer"
          image_tag        = "2.0.33"
        },
        "notaryservice" = {
          security_context = false
          target_port      = 8080
          url_prefix       = "/notary"
          image_tag        = "2.0.12"
        },
        "swiftservice" = {
          security_context = false
          target_port      = 8080
          url_prefix       = "/swift"
          image_tag        = "2.0.18"
        },
        "datagenerator" = {
          security_context = false
          target_port      = 8080
          port             = 8080
          image_tag        = "2.0.428"
          url_prefix       = ""
          health_endpoint  = null
        },
        "dashboard-trades" = {
          security_context = false
          subdomain_suffix = "-trades"
          target_port      = 80
          port             = 8080
          image_tag        = "2.0.12"
          url_prefix       = ""
          health_endpoint  = "/health"
        }
      }
    }
  }
}

variable "rabbitmq_engine_version" {
  description = "Version of the RabbitMQ broker engine"
  type        = string
  default     = "3.13"
}

variable "rabbitmq_enable_cluster_mode" {
  description = "Enable RabbitMQ Cluster Mode. Default is `false`"
  type        = bool
  default     = false
}

variable "rabbitmq_instance_type" {
  description = "Broker's instance type"
  type        = string
  default     = "mq.m5.large"
}

variable "rabbitmq_auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available. Default is `false`"
  type        = bool
  default     = true
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

variable "rabbitmq_whitelist_ips" {
  description = "List of IPv4 CIDR blocks to whitelist to RabbitMQ (ingress)"
  type        = list(string)
  default     = []
}

variable "k8s_cluster_name" {
  description = "Name of the EKS cluster where applications should be deployed"
  type        = string
  default     = "test"
}

variable "create_dns_records" {
  default = false
}

variable "cloudflare_api_token" {
  description = "API token to access cloudflare"
  type        = string
}

variable "env_secrets" {
  description = "AWS secret name containing the secrets to be appended"
  type        = string
  default     = ""
}

variable "additional_secrets" {
  description = "additional map of secrets to be saved in secrets manager"
  type        = map(any)
  default     = {}
}

variable "tgw_shared_accounts" {
  type    = list(string)
  default = []
}

variable "tgw_region_routes" {
  type = map(list(string))
  default = {
    "us-east-1"      = [],
    "us-west-2"      = [],
    "ap-southeast-1" = [],
    "eu-west-1"      = []
  }
}


variable "opensearch_admin_username" {
  description = "Admin username for OpenSearch"
  type        = string
}

variable "opensearch_admin_password" {
  description = "Admin password for OpenSearch"
  type        = string
  sensitive   = true
}

variable "opensearch_host_url" {
  description = "Host URL for OpenSearch cluster (must include https://)"
  type        = string
  validation {
    condition     = can(regex("^https://", var.opensearch_host_url))
    error_message = "The opensearch_host_url must start with https://"
  }
}

variable "opensearch_version" {
  description = "Version of OpenSearch to Connect to"
  type        = string
  default     = "2.11"
}

variable "opensearch_alert_slack_webhook_url" {
  description = "Slack webhook URL for OpenSearch alerts"
  type        = string
  default     = ""
}

variable "opensearch_alert_gchat_webhook_url" {
  description = "Google Chat webhook URL for OpenSearch alerts"
  type        = string
  default     = ""
}

variable "opensearch_alert_gchat_high_priority_webhook_url" {
  description = "Google Chat high priority webhook URL for OpenSearch alerts"
  type        = string
  default     = ""
}

variable "opensearch_alert_pagerduty_integration_key" {
  description = "PagerDuty integration key for OpenSearch alerts"
  type        = string
  default     = ""
}

variable "opensearch_alert_ses_email_account_id" {
  description = "SES email account ID for OpenSearch alerts"
  type        = string
  default     = ""
}

variable "opensearch_alert_ses_email_recipients" {
  description = "SES email recipients for OpenSearch alerts"
  type        = list(string)
  default     = []
}


variable "nlb_ingress_whitelist" {
  type    = list(string)
  default = []
}

variable "rabbitmq_lb_ingress_whitelist" {
  description = "IP address over which rabbitmq nlb is restricted"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "CA signed public certificate arn for Rabbitmq NLB"
  type        = string
}

variable "keys_s3_bucket" {
  description = "Bucket name to store the private SSh keys in"
  type        = string
}

variable "triana_sftp_host_endpoint" {
  description = "IP or URL of the TRIANA SFTP server for SWIFT messages"
  type        = string
  default     = null
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
  type = string
}

variable "vendor" {
  type = string
}

variable "dr_central_vpc_subnet_ids" {
  type    = list(string)
  default = null
}

variable "dr_central_vpc_id" {
  type    = string
  default = null
}

variable "vpc_id" {}
variable "eks_security_group" {}
variable "kms_key_arn" {}
variable "eks_node_role_arn" {}
variable "eks_cluster_role_arn" {}
variable "external_loadbalancer_url" {}