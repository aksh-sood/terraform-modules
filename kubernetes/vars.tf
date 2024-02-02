variable "lbc_addon_version" {
  description = "Load Balancer Controller helm chart version number"
  type        = string
  default     = "1.6.0"
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

variable "baton_application_namespaces" {
  description = "List of namespaces, services and there required attributes"
  type = list(object({
    namespace       = string
    istio_injection = bool
    common_env      = optional(map(string), {})
    services = list(object({
      name             = string
      customer         = string
      health_endpoint  = string
      target_port      = number
      subdomain_suffix = optional(string, "")
      url_prefix       = string
      env              = map(string)
      image_tag        = optional(string, "latest")
    }))
  }))
}

variable "enable_siem" {
  default = true
}

variable "opensearch_password" {}
variable "opensearch_username" {}
variable "opensearch_endpoint" {}
