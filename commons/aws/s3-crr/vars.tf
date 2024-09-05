variable "primary_bucket_name" {
  description = "Name of the bucket in primary region to replicate"
  type        = string
}

variable "secondary_bucket_name" {
  description = "Name of the bucket in secondary region to replicate"
  type        = string
}

variable "primary_kms_key" {
  description = "ARN of the KMS key used to encrypt the primary bucket"
  type        = string
}

variable "secondary_kms_key" {
  description = "ARN of the KMS key used to encrypt the secondary bucket"
  type        = string
}

variable "name" {}