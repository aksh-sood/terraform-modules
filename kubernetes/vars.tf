variable "efs_addon_version" {
  type        = string
  description = "EFS helm chart version number"
  default     = "2.2.0"
}

variable "lbc_addon_version" {
  description = "Load Balancer Controller helm chart version number"
  type        = string
  default     = "1.6.0"
}

variable "environment" {
  description = "Environment for which the resources are being provisioned"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "arn id of the ACM certificate to be used by load balancer"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain Name registered in DNS service"
  type        = string
  default     = ""
}

variable "istio_version" {
  description = "istio helm chart version"
  type        = string
  default     = "1.20.0"
}

variable "siem_storage_s3_bucket" {
  description = "bucket id for alerts and logging"
  type        = string
  default     = ""
}

variable "kube_prometheus_stack_version" {
  description = "Kube prometheus stack helm chart version"
  type        = string
  default     = "49.2.0"
}

variable "efs_id" {
  description = "EFS ID for persistent volume in EKS cluster"
  type        = string
  default     = ""
}

variable "slack_web_hook" {
  description = "Slack Webhook for alerts notification from prometheus alert manager"
  type        = string
  default     = "https://hooks.slack.com/services/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"
}

variable "slack_channel_name" {
  description = "Slack channel for alerts notification from prometheus alert manager"
  type        = string
  default     = "terraform-test-alerts"
}

variable "pagerduty_key" {
  description = "PagerDuty key for alerts notification from prometheus alert manager"
  type        = string
  default     = ""
}

variable "grafana_role_arn" {
  description = "IAM Role ARN for cloudwatch data source in grafana"
  type        = string
  default     = ""
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

variable "os_password" {
  
}

variable "os_username" {
  
}

variable "os_endpoint" {
  
}