variable "slack_webhook_url" {
  type        = string
  default     = ""
  description = "The webhook URL for Slack notifications"
}

variable "gchat_webhook_url" {
  type        = string
  default     = ""
  description = "The webhook URL for Google Chat notifications"
}

variable "gchat_high_priority_webhook_url" {
  type        = string
  default     = ""
  description = "The webhook URL for high priority Google Chat notifications"
}

variable "pagerduty_integration_key" {
  type        = string
  default     = null
  description = "The integration key for PagerDuty notifications"
}

variable "ses_email_account_id" {
  type        = string
  default     = ""
  description = "The AWS account ID for SES email notifications"
}

variable "ses_email_recipients" {
  type        = list(string)
  default     = []
  description = "List of email addresses to receive SES notifications"
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
  type        = string
  description = "The AWS region to deploy resources"
}

variable "ses_email_config" {
  type = object({
    region       = string
    role_arn     = string
    from_address = string
  })
  description = "SES Email configuration for sending email alerts"
  default     = null
}
