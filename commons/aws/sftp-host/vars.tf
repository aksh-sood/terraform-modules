variable "ingress_whitelist" {
  type    = list(string)
  default = []
}

variable "disable_api_termination" {
  type    = bool
  default = true
}

variable "disable_api_stop" {
  type    = bool
  default = true
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "ami_id" {
  default = "ami-04a81a99f5ec58529"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "region" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "eks_security_group" {}
variable "keys_s3_bucket" {}
variable "tags" {}
variable "kms_key_id" {}