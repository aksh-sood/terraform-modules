variable "baton_application_namespaces" {
  description = "List of namespaces, services and there required attributes"
  type = list(object({
    namespace       = string
    customer        = string
    istio_injection = bool
    common_env      = optional(map(string), {})
    services = list(object({
      name             = string
      health_endpoint  = string
      target_port      = number
      subdomain_suffix = optional(string, "")
      url_prefix       = string
      env              = map(string)
      image_tag        = optional(string, "latest")
    }))
  }))
}

variable "common_connections" {
  default = {}
}

variable "domain_name" {}
variable "environment" {}