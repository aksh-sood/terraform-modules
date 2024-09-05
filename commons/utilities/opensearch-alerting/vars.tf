
variable "ses_email_account_id" {
  type        = string
  description = "SES Email Account ID for sending email alerts"
  default     = ""
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
variable "pagerduty_integration_key" {
  type        = string
  description = "PagerDuty Integration Key for sending alerts"
  sensitive   = true
  default     = ""
}

variable "monitor_path" {
  type        = string
  description = "Path to the directory containing monitor JSON files"
}
