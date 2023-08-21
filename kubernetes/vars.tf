variable "efs_version" {
  type    = string
  default = "2.2.0"
}

variable "lbc_version" {
  type    = string
  default = "1.6.0"
}

variable "environment" {
  type    = string
  default = ""
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "istio_version" {
  type    = string
  default = "1.18.0"
}

variable "siem_storage_s3_bucket" {
  type    = string
  default = ""
}