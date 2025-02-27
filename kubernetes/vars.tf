variable "lbc_addon_version" {
  description = "Load Balancer Controller helm chart version number"
  type        = string
  default     = "1.6.0"
}

variable "region" {
  description = "Region of aws provider to run on"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment for which the resources are being provisioned"
  type        = string
}

variable "acm_certificate_arn" {
  description = "arn id of the ACM certificate to be used by load balancer"
  type        = string
}

variable "domain_name" {
  description = "Domain Name registered in DNS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}\\.[a-zA-Z]{2,6}$", var.domain_name))
    error_message = "Domain name should be valid (e.g., example.com)"
  }
}

variable "istio_version" {
  description = "istio helm chart version"
  type        = string
  default     = "1.20.0"
}

variable "siem_storage_s3_bucket" {
  description = "bucket id for alerts and logging"
  type        = string
}

variable "kube_prometheus_stack_version" {
  description = "Kube prometheus stack helm chart version"
  type        = string
  default     = "49.2.0"
}

variable "node_exporter_version" {
  description = "Node exporter version for helm chart"
  type        = string
  default     = "1.7.0"
}

variable "kube_state_metrics_version" {
  description = "Kube state metrics version for helm chart"
  type        = string
  default     = "2.1.1"
}

variable "efs_id" {
  description = "EFS ID for persistent volume in EKS cluster"
  type        = string
}

variable "slack_web_hook" {
  description = "Slack Webhook for alerts notification from prometheus alert manager"
  type        = string
}

variable "slack_channel_name" {
  description = "Slack channel for alerts notification from prometheus alert manager"
  type        = string
}

variable "pagerduty_key" {
  description = "PagerDuty key for alerts notification from prometheus alert manager"
  type        = string
}

variable "grafana_role_arn" {
  description = "IAM Role ARN for cloudwatch data source in grafana"
  type        = string
}

variable "custom_alerts" {
  description = "custom prometheus alerts"
  type = list(
    object({
      alert = string
      expr  = string
      for   = string
      labels = object({
        severity = string
      })
      annotations = object({
        summary     = string
        description = string
      })
    })
  )

  default = []
}

variable "bitbucket_key_secrets_manager_name" {
  description = "Name of the secret storing ssh key to configure into k8s secrets of config server"
  type        = string
  default     = ""
}

variable "config_repo_url" {
  description = "SSH link to config repo repository for configuring ENV variables of applications"
  type        = string
  default     = "git@bitbucket.org:ubixi/config-repo.git"
}

variable "config_server_image_tag" {
  description = "Version of the config-server to deploy"
  type        = number
  default     = 59
}

variable "enable_config_server" {
  description = "Whether to enable config server"
  type        = bool
  default     = true
}

variable "alert_manager_volume_size" {
  type        = string
  description = "Volume Claims size for alert manager"
  default     = "5Gi"
}

variable "prometheus_volume_size" {
  type        = string
  description = "Volume Claims size for alert manager"
  default     = "200Gi"
}

variable "cloudflare_api_token" {
  description = "API token to access cloudflare"
  type        = string
}

variable "enable_siem" {
  default = true
}

variable "create_dns_records" {
  default = true
}

variable "enable_sftp" {
  description = "Deploy SFTP server in Kubernetes cluster"
  default     = true
}

variable "sftp_namespace" {
  description = "Namespace to deploy SFTP server in"
  type        = string
  default     = "sftp"
}

variable "sftp_username" {
  description = "username for SFTP server"
  type        = string
  default     = "myuser"
}

variable "enable_cluster_autoscaler" {
  description = "Whether to install cluster autoscaler or not"
  type        = bool
  default     = false
}

variable "cluster_autoscaler_version" {
  description = "Version of cluster autoscaler to install"
  type        = string
  default     = "v1.26.2"
}

variable "lambda_packages_s3_bucket" {
  description = "S3 bucket name with JAR packages for lambda functions"
  type        = string
  default     = "fx-dev-lambda-packages"
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

variable "elb_security_group" {
  description = "security group for load balancers"
  type        = string
}

variable "internal_alb_security_group" {
  description = "value"
  type        = string
}

variable "gchat_webhook" {
  default = null
  type    = string
}

variable "curator_image_tag" {
  type    = string
  default = "1.1.7"
}

variable "create_s3_bucket_for_curator" {
  type    = bool
  default = true
}

variable "custom_s3_bucket_for_curator" {
  type        = string
  default     = null
  description = "User provided s3 bucket that curator should use for backing up"
  validation {
    condition     = !(var.create_s3_bucket_for_curator == true && (var.custom_s3_bucket_for_curator != null && var.custom_s3_bucket_for_curator != ""))
    error_message = "If the variable create_s3_bucket_for_curator is set to true, then the variable custom_s3_bucket_for_curator should be null"
  }
  validation {
    condition     = !(var.create_s3_bucket_for_curator == false && (var.custom_s3_bucket_for_curator == null || var.custom_s3_bucket_for_curator == ""))
    error_message = "If the variable create_s3_bucket_for_curator is set to false then a custom s3 bucket should be provided in the variable custom_s3_bucket_for_curator"
  }
}

variable "prometheus_custom_alerts" {
  description = "custom prometheus alerts"
  type = list(
    object({
      alert = string
      expr  = string
      for   = string
      labels = object({
        severity = string
      })
      annotations = object({
        summary     = string
        description = string
      })
    })
  )

  default = []
}

variable "waf_arn" {
  description = "ARN of the WAF to associate with resources"
  type        = string
  default     = ""
}

variable "vendor" {}
variable "opensearch_password" {}
variable "opensearch_username" {}
variable "opensearch_endpoint" {}
variable "curator_iam_user_arn" {}
variable "curator_iam_role_arn" {}
variable "curator_iam_user_access_key" {}
variable "curator_iam_user_secret_key" {}
variable "s3_bucket_for_curator" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}
