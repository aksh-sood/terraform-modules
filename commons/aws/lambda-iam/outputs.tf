output "lambda_role_arn" {
  description = "ARN of the IAM role created for Lambda functions"
  value       = aws_iam_role.lambda_role.arn
}