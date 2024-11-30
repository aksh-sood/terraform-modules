output "arn" {
  description = "ARN of the WAF"
  value       = aws_wafv2_web_acl.this.arn
}
