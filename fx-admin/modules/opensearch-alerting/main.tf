terraform {
  required_providers {
    opensearch = {
      source                = "opensearch-project/opensearch"
      configuration_aliases = [opensearch.this]
    }
  }
}

module "opensearch_monitors" {
  source = "../../../commons/utilities/opensearch-alerting"

  monitor_path                    = "${path.module}/monitors"
  slack_webhook_url               = var.slack_webhook_url
  gchat_webhook_url               = var.gchat_webhook_url
  gchat_high_priority_webhook_url = var.gchat_high_priority_webhook_url
  pagerduty_integration_key       = var.pagerduty_integration_key
  ses_email_account_id            = var.ses_email_account_id
  ses_email_recipients            = var.ses_email_recipients

  providers = {
    opensearch.this = opensearch.this
  }
}
