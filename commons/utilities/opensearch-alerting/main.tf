terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3.0"
    }
  }
}

provider "opensearch" {
  url                = "https://${var.opensearch_endpoint}:443"
  aws_region         = var.region
  username           = var.opensearch_username
  password           = var.opensearch_password
  sign_aws_requests  = false
  healthcheck        = false
  opensearch_version = var.opensearch_version
}

resource "opensearch_monitor" "dynamic_monitors" {
  for_each = fileset(var.monitor_path, "*.json")

  body = templatefile("${var.monitor_path}/${each.key}", {
    slack_channel_id               = length(opensearch_channel_configuration.slack) > 0 ? opensearch_channel_configuration.slack[0].id : "",
    gchat_channel_id               = length(opensearch_channel_configuration.gchat) > 0 ? opensearch_channel_configuration.gchat[0].id : "",
    gchat_high_priority_channel_id = length(opensearch_channel_configuration.gchat_high_priority) > 0 ? opensearch_channel_configuration.gchat_high_priority[0].id : "",
    pagerduty_channel_id           = length(opensearch_channel_configuration.pagerduty) > 0 ? opensearch_channel_configuration.pagerduty[0].id : "",
    pagerduty_integration_key      = var.pagerduty_integration_key != null ? var.pagerduty_integration_key : "",
    email_channel_id               = length(opensearch_channel_configuration.email_notification) > 0 ? opensearch_channel_configuration.email_notification[0].id : ""
  })


  lifecycle {
    ignore_changes = [body]
  }
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
  count = var.pagerduty_integration_key != null ? 1 : 0
  body = jsonencode({
    config_id = "pagerduty"
    config = {
      name        = "pagerduty"
      description = "PagerDuty Destination for Application Alerts"
      config_type = "webhook"
      is_enabled  = true
      webhook = {
        url = "https://events.pagerduty.com/v2/enqueue"
        header_params = {
          "Content-Type" = "application/json"
        }
        method = "POST"
      }
    }
  })
}

resource "opensearch_channel_configuration" "ses_email" {
  count = var.ses_email_config != null ? 1 : 0
  body = jsonencode({
    config_id = "ses_email"
    config = {
      name        = "ses_email"
      description = "SES Email Destination for Application Alerts"
      config_type = "ses_account"
      is_enabled  = true
      ses_account = var.ses_email_config
    }
  })
}

resource "opensearch_channel_configuration" "email_notification" {
  count = var.ses_email_config != null ? 1 : 0
  body = jsonencode({
    config_id = "email_notification"
    config = {
      name        = "email_notification"
      description = "Email Notification Channel for Application Alerts"
      config_type = "email"
      is_enabled  = true
      email = {
        email_account_id = opensearch_channel_configuration.ses_email[0].id
        recipients       = var.ses_email_recipients
      }
    }
  })
}
