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

variable "enable_gateway" {
  description = "Whether to create a gateway in the namespace or not"
  type = bool
  default = true
}

variable "volumeMounts" {
  type = object({
      volumes = list(object({
        name = string
        volumeType =string
        config=map(string)
    }))
    mounts = list(object({
      mountPath = string
      name      = string
      subPath   = string
    }))
    })
  default =     {
      volumes = []
      mounts = []
    }
}

variable "domain_name" {}
variable "namespace" {}
variable "customer" {}
variable "common_env" {}
variable "istio_injection" {}