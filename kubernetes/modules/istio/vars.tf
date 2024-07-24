variable "acm_certificate_arn" {
  description = "certificate arn for istio ingress application load balancer"
  type        = string
}

variable "alb_base_attributes" {
  description = "annotations for configuring alb"
  type        = string
  default     = "deletion_protection.enabled=false,routing.http.drop_invalid_header_fields.enabled=true"
}

variable "istio_version" {}
variable "siem_storage_s3_bucket" {}
variable "enable_siem" {}
variable "domain_name" {}
variable "environment" {}
variable "security_group" {}
variable "internal_alb_security_group" {}
