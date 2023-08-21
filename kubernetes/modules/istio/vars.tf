variable "acm_certificate_arn" {
  description = "certificate arn for istio ingress application load balancer"
  type        = string
}

variable "istio_version" {}
variable "siem_storage_s3_bucket" {}
