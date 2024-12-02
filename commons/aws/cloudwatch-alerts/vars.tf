variable "cloudwatch_alerts" {
  type = map(object({
    name                = string
    description         = string
    metric_name         = string
    comparison_operator = string
    threshold           = number
    namespace           = string
    statistic           = string
    period              = string
    datapoints_to_alarm = string
    treat_missing_data  = string
    dimensions          = map(string)
  }))
}

variable "environment" {}
variable "region" {}
variable "kms_key_arn" {}
variable "email_ids" {}
variable "gchat_lambda" {}
variable "gchat_lambda_arn" {}
variable "pagerduty_integration_key" {}