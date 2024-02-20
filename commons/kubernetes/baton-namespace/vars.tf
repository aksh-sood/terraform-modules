variable "services" {
  description = "List of services and there required attributes"
  type = list(object({
    name             = string
    health_endpoint  = string
    target_port      = number
    subdomain_suffix = optional(string, "")
    url_prefix       = string
    env              = map(string)
    image_tag        = optional(string, "latest")
  }))
}

variable "domain_name" {}
variable "environment" {}
variable "namespace" {}
variable "customer" {}
variable "common_env" {}
variable "istio_injection" {}