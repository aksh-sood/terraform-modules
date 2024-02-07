terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "2.3.3"
    }
  }
}

provider "grafana" {

  url  = "https://${var.environment}-grafana.${var.domain_name}"
  auth = "admin:${var.grafana_password}"
}

resource "grafana_folder" "custom" {
  title = "Custom Dashboards"

  depends_on = [var.vs_dependency]
}

resource "grafana_dashboard" "metrics" {
  for_each = fileset("${path.module}/dashboards", "*.json")

  config_json = file("${path.module}/dashboards/${each.key}")
  folder      = grafana_folder.custom.id

  depends_on = [var.vs_dependency]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_special      = 1
  lower            = true
  min_lower        = 1
  numeric          = true
  min_numeric      = 1
  upper            = true
  min_upper        = 1
}

resource "grafana_user" "developer" {
  email    = "dev@batonsystems.com"
  name     = "developer"
  password = random_password.password.result
  is_admin = false

  depends_on = [var.vs_dependency]
}

resource "grafana_data_source" "cloudwatch" {
  name = "CloudWatch"
  type = "cloudwatch"

  json_data_encoded = <<JSON
{
  "authType": "assumeRole",
  "assumeRoleArn": "${var.grafana_role_arn}",
  "defaultRegion": "us-east-1"
}
JSON

  depends_on = [var.vs_dependency]
}