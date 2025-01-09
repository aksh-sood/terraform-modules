variable "storage_type" {
  type    = string
  default = "efs"
}

variable "ingress_whitelist_ips" {
  type = list(string)
}

variable "egress_whitelist_ips" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "maintenance_window" {
  type = object({
    day       = string
    time      = string
    time_zone = string
  })
}

variable "broker_connections" {
  type = map(object({
    uri       = string
    user_name = string
  }))
  default = {}
}

variable "replica_username" {
  type    = string
  default = "replica_user"
}

variable "data_replication_mode" {
  type    = string
  default = "NONE"
}

variable "primary_broker_arn" {
  type    = string
  default = null
}

variable "replica_password" {
  type    = string
  default = null
}

variable "name" {}
variable "region" {}
variable "vpc_id" {}
variable "whitelist_security_groups" {}
variable "tags" {}
variable "engine_version" {}
variable "instance_type" {}
variable "apply_immediately" {}
variable "auto_minor_version_upgrade" {}
variable "publicly_accessible" {}
variable "deployment_mode" {}
variable "username" {}