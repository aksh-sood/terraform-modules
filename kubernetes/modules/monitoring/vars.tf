variable "grafana_volume_size" {
  type        = string
  description = "Volume Claims size for alert manager"
  default     = "10Gi"
}

variable "cnames" {
  type    = list(string)
  default = ["prometheus", "grafana", "alertmanager"]
}

variable "cloudflare_api_token" {}
variable "alert_manager_volume_size" {}
variable "prometheus_volume_size" {}
variable "slack_web_hook" {}
variable "slack_channel_name" {}
variable "kube_prometheus_stack_version" {}
variable "pagerduty_key" {}
variable "custom_alerts" {}
variable "grafana_role_arn" {}
variable "environment" {}
variable "domain_name" {}
variable "isito_dependency" {}
variable "loadbalancer_url" {}