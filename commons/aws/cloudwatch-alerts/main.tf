data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_cloudwatch_invoke" {
  statement_id  = "AllowCloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.gchat_lambda
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = "arn:aws:cloudwatch:${var.region}:${data.aws_caller_identity.current.account_id}:alarm:*"
}

resource "aws_iam_role" "SuccessFeedbackRole" {
  name = "${var.environment}-${var.region}-sns-success-feedback-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "AllowSNSSuccessFeedback"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ],
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "FailureFeedbackRole" {
  name = "${var.environment}-${var.region}-sns-failure-feedback-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "AllowSNSSuccessFeedback"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ],
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_sns_topic" "production_alerts" {
  name                              = "${var.environment}-production-alerts-${var.region}"
  http_failure_feedback_role_arn    = aws_iam_role.FailureFeedbackRole.arn
  http_success_feedback_role_arn    = aws_iam_role.SuccessFeedbackRole.arn
  http_success_feedback_sample_rate = "100"
}

resource "aws_sns_topic_subscription" "pagerduty" {
  count     = var.pagerduty_integration_key != null && var.pagerduty_integration_key != "" ? 1 : 0

  topic_arn = aws_sns_topic.production_alerts.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/${var.pagerduty_integration_key}/enqueue"
}

resource "aws_sns_topic_subscription" "email" {
  for_each     = toset(var.email_ids)

  topic_arn = aws_sns_topic.production_alerts.arn
  protocol  = "email"
  endpoint  = each.key
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alerts" {
  for_each            = var.cloudwatch_alerts

  alarm_name          = each.value["name"]
  alarm_description   = each.value["description"]
  metric_name         = each.value["metric_name"]
  comparison_operator = each.value["comparison_operator"]
  threshold           = each.value["threshold"]
  evaluation_periods  = each.value["datapoints_to_alarm"] #evaluation period should be same as datapoints to alarm
  namespace           = each.value["namespace"]
  statistic           = each.value["statistic"]
  period              = each.value["period"]
  datapoints_to_alarm = each.value["datapoints_to_alarm"]
  treat_missing_data  = each.value["treat_missing_data"]
  dimensions          = each.value["dimensions"]
  alarm_actions = [
    aws_sns_topic.production_alerts.arn,
    var.gchat_lambda_arn != null ? var.gchat_lambda_arn : ""
  ]
  ok_actions = [
    aws_sns_topic.production_alerts.arn,
    var.gchat_lambda_arn != null ? var.gchat_lambda_arn : ""
  ]

}
