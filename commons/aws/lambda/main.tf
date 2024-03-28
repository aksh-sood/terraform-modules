resource "aws_lambda_function" "this" {
  s3_bucket     = var.lambda_packages_s3_bucket
  s3_key        = var.package_key
  function_name = var.name
  role          = var.lambda_role_arn
  handler       = var.handler
  runtime       = "java8.al2"
  memory_size   = 1024
  timeout       = 300
  tags          = var.tags

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group]
  }

  environment {
    variables = var.environment_variables
  }

}

resource "aws_lambda_event_source_mapping" "this" {
  function_name     = aws_lambda_function.this.arn
  enabled           = true
  batch_size        = var.stream_arn == null && var.sqs_arn != null ? 10 : 25
  starting_position = var.stream_arn == null && var.sqs_arn != null ? null : "LATEST"
  event_source_arn  = var.stream_arn == null && var.sqs_arn != null ? var.sqs_arn : var.stream_arn

  lifecycle {
    precondition {
      condition     = !((var.stream_arn == null && var.sqs_arn == null) || (var.stream_arn != null && var.sqs_arn != null))
      error_message = "Either of stream_arn or sqs_arn are required. Please supply any one of them if none provided or remove any one if both provided"
    }
  }
}