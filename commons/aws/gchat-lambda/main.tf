locals {
  env_vars       = { gchat_webhook_url = var.gchat_webhook_url }
  slack_env_vars = var.slack_webhook_url != null ? { slack_webhook_url = var.slack_webhook_url } : {}
}

resource "aws_lambda_function" "this" {
  function_name = "${var.name}-gchat-lambda"
  runtime       = "python3.10"
  handler       = "lambda.lambda_handler"
  publish       = true
  memory_size   = 128
  timeout       = 75
  s3_bucket     = var.lambda_packages_s3_bucket
  s3_key        = var.package_key
  role          = aws_iam_role.lambda_execution_role.arn


  environment {
    variables = merge(local.env_vars, local.slack_env_vars)
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = var.tags
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole-${var.region}-${var.environment}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "LambdaExecutionPolicy-${var.region}-${var.environment}"
  description = "Allows Lambda to send logs to CloudWatch and access S3 bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "arn:aws:s3:::${var.lambda_packages_s3_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"
}
