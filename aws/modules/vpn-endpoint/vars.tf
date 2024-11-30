variable "validity_period_hours" {
  description = "give the  certificate  validity period in hours"
  type        = string
  default     = "87600"
}

variable "saml_provider_name" {
  description = "Name for SAML Provider"
  type        = string
  default     = "Jump_cloud_Client_VPN"
}

variable "organization_name" {
  description = "Name of organization to use in private certificate"
  type        = string
  default     = "Baton Systems"
}

variable "target_network_cidr" {
  description = "IP of target Network cidr Block"
}

variable "subnet_id" {
  description = "Subnet ID to associate to endpoint (taken first private subnet form vpc module)"
}

variable "enable_split_tunnel" {
  description = "Boolean to enable split tunneling in vpn endpoint"
  type        = bool
  default     = false
}

variable "client_cidr_block" {
  default = "10.9.0.0/16"
}

variable "name" {}
variable "region" {}
variable "vpc_id" {}
variable "cost_tags" {}
variable "access_group_id" {}
variable "acm_certificate_arn" {}
variable "saml_metadata_bucket" {}
variable "saml_metadata_object_key" {}
