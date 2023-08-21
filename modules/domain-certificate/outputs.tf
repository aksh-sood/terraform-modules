output "certificate_arn" {
  description = "acm of certificate arn"
  value       = aws_acm_certificate.acm_cert.arn
}