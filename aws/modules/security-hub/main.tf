data "aws_caller_identity" "current" {}

resource "aws_securityhub_account" "default" {
  enable_default_standards = false
  auto_enable_controls     = true
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each      = toset(var.security_hub_standards)
  standards_arn = "arn:aws:securityhub:${var.region}::standards/${each.key}"

  depends_on = [aws_securityhub_account.default]
}

resource "aws_securityhub_standards_control" "disable_controls" {
  for_each              = var.disabled_security_hub_controls
  standards_control_arn = "arn:aws:securityhub:${var.region}:${data.aws_caller_identity.current.account_id}:control/${each.key}"
  control_status        = "DISABLED"
  disabled_reason       = each.value

  depends_on = [aws_securityhub_standards_subscription.this]
}
