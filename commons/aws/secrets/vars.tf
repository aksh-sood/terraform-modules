variable "name" {
  description = "Name of the environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key to use"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to push in secrets manager"
  type        = map(string)
}