data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {
  name = "FX_lambda_role-${var.name}-${var.region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
    EOF
}

locals {
  managed_lambda_policies_map = {
    for policy_arn in var.lambda_role_policies :
    policy_arn => "arn:aws:iam::aws:policy/${policy_arn}"
  }
  lambda_policies_map = merge(local.managed_lambda_policies_map,
    {
      LambdaPermission = aws_iam_policy.lambda_policy.arn
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "FX-lambda-policy_${var.name}_${var.region}"

  policy = templatefile("${path.module}/templates/lambda.json", {
    region        = var.region,
    account_id    = data.aws_caller_identity.current.account_id
    s3_bucket_arn = var.s3_bucket_arn
    sqs_queue_arn = var.sqs_queue_arn
    streams_arn   = join(",", formatlist("\"%s\"", var.streams_arn))
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role" {
  for_each = { for k, v in local.lambda_policies_map : k => v }

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value
}
