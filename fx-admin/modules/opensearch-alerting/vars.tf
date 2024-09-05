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
  default     = ""
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
