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

variable "secret_name" {
  description = "Name of the secret storing ssh key to configure into config map of config server"
  type        = string
}

variable "enable_config_server" {
  description = "Whether to enable config server"
  type = bool
  default = true
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
  type        = string
  description = "api token to access cloudflare"
}

variable "enable_siem" {
  default = true
}

variable "create_dns_records" {
  default = true
}

variable "opensearch_password" {}
variable "opensearch_username" {}
variable "opensearch_endpoint" {}
