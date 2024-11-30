

module "opensearch_monitors" {
  source = "../../../commons/utilities/opensearch-alerting"

  opensearch_endpoint             = var.opensearch_endpoint
  monitor_path                    = "${path.cwd}/${path.module}/monitors"
  slack_webhook_url               = var.slack_webhook_url
  gchat_webhook_url               = var.gchat_webhook_url
  gchat_high_priority_webhook_url = var.gchat_high_priority_webhook_url
  pagerduty_integration_key       = var.pagerduty_integration_key
  ses_email_recipients            = var.ses_email_recipients
  opensearch_password             = var.opensearch_password
  opensearch_username             = var.opensearch_username
  region                          = var.region
  ses_email_config                = var.ses_email_config

}
