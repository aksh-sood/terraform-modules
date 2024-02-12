
resource "aws_iam_role" "lambda_role" {
  name = "FX_lambda_role-${var.environment}-${var.region}"

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

resource "aws_iam_role_policy_attachment" "lambda_role" {
  for_each = var.lambda_role_policies

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
