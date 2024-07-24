variable "ingress_whitelist_ips" {
  type = list(string)
}

variable "egress_whitelist_ips" {
  type = list(string)
}

variable "name" {}
variable "region" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "whitelist_security_groups" {}
variable "tags" {}
variable "engine_version" {}
variable "storage_type" {}
variable "instance_type" {}
variable "apply_immediately" {}
variable "auto_minor_version_upgrade" {}
variable "publicly_accessible" {}
variable "username" {}