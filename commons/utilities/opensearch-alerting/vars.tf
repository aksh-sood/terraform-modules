variable "ses_email_config" {
  type = object({
    region       = string
    role_arn     = string
    from_address = string
  })
  description = "SES Email configuration for sending email alerts"
  default     = null
}

variable "ses_email_recipients" {
  type        = list(string)
  description = "List of email addresses to receive SES email alerts"
  default     = []
}

variable "gchat_high_priority_webhook_url" {
  type        = string
  description = "Webhook URL for Google Chat high priority notifications"
  sensitive   = true
  default     = ""
}

variable "slack_webhook_url" {
  type        = string
  description = "Webhook URL for Slack notifications"
  sensitive   = true
  default     = ""
}

variable "gchat_webhook_url" {
  type        = string
  description = "Webhook URL for Google Chat notifications"
  sensitive   = true
}

variable "monitor_path" {
  type        = string
  description = "Path to the directory containing monitor JSON files"
}


variable "opensearch_username" {
  description = "Admin username for OpenSearch"
  type        = string
}

variable "opensearch_password" {
  description = "Admin password for OpenSearch"
  type        = string
  sensitive   = true
}

variable "opensearch_endpoint" {
  description = "Host URL for OpenSearch cluster (must include https://)"
  type        = string
}

variable "opensearch_version" {
  description = "Version of OpenSearch to Connect to"
  type        = string
  default     = "2.11"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "pagerduty_integration_key" {
  description = "Integration key for PagerDuty notifications"
  type        = string
  sensitive   = true
  default     = null
}
