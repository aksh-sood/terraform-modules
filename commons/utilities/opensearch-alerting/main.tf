terraform {
  required_providers {
    opensearch = {
      source                = "opensearch-project/opensearch"
      configuration_aliases = [opensearch.this]
    }
  }
}

locals {
  monitor_files = fileset(var.monitor_path, "*.json")
  monitors = {
    for file in local.monitor_files :
    basename(file) => jsondecode(file("${var.monitor_path}/${file}"))
  }
}

resource "opensearch_monitor" "dynamic_monitors" {
  for_each = local.monitors
  body = templatefile("${var.monitor_path}/${each.key}", {
    slack_channel_id               = length(opensearch_channel_configuration.slack) > 0 ? opensearch_channel_configuration.slack[0].id : null,
    gchat_channel_id               = length(opensearch_channel_configuration.gchat) > 0 ? opensearch_channel_configuration.gchat[0].id : null,
    gchat_high_priority_channel_id = length(opensearch_channel_configuration.gchat_high_priority) > 0 ? opensearch_channel_configuration.gchat_high_priority[0].id : null,
    pagerduty_channel_id           = length(opensearch_channel_configuration.pagerduty) > 0 ? opensearch_channel_configuration.pagerduty[0].id : null,
    ses_email_channel_id           = length(opensearch_channel_configuration.ses_email) > 0 ? opensearch_channel_configuration.ses_email[0].id : null
  })
}

resource "opensearch_channel_configuration" "slack" {
  count = var.slack_webhook_url != "" ? 1 : 0
  body = jsonencode({
    config_id = "slack"
    config = {
      name        = "slack"
      description = "Slack Destination for Application Alerts"
      config_type = "slack"
      is_enabled  = true
      slack = {
        url = var.slack_webhook_url
      }
    }
  })
}

resource "opensearch_channel_configuration" "gchat" {
  count = var.gchat_webhook_url != "" ? 1 : 0
  body = jsonencode({
    config_id = "gchat"
    config = {
      name        = "gchat"
      description = "Google Space Destination for Application Alerts"
      config_type = "webhook"
      is_enabled  = true
      webhook = {
        url = var.gchat_webhook_url
        header_params = {
          "Content-Type" = "application/json"
        }
        method = "POST"
      }
    }
  })
}

resource "opensearch_channel_configuration" "gchat_high_priority" {
  count = var.gchat_high_priority_webhook_url != "" ? 1 : 0
  body = jsonencode({
    config_id = "gchat_high_priority"
    config = {
      name        = "gchat_high_priority"
      description = "Google Space Destination for High Priority Application Alerts"
      config_type = "webhook"
      is_enabled  = true
      webhook = {
        url = var.gchat_high_priority_webhook_url
        header_params = {
          "Content-Type" = "application/json"
        }
        method = "POST"
      }
    }
  })
}

resource "opensearch_channel_configuration" "pagerduty" {
  count = var.pagerduty_integration_key != "" ? 1 : 0
  body = jsonencode({
    config_id = "pagerduty"
    config = {
      name        = "pagerduty"
      description = "PagerDuty Destination for Application Alerts"
      config_type = "pagerduty"
      is_enabled  = true
      pagerduty = {
        integration_key = var.pagerduty_integration_key
      }
    }
  })
}

resource "opensearch_channel_configuration" "ses_email" {
  count = var.ses_email_account_id != "" ? 1 : 0
  body = jsonencode({
    config_id = "ses_email"
    config = {
      name        = "ses_email"
      description = "SES Email Destination for Application Alerts"
      config_type = "email"
      is_enabled  = true
      email = {
        email_account_id = var.ses_email_account_id
        recipients       = var.ses_email_recipients
      }
    }
  })
}
