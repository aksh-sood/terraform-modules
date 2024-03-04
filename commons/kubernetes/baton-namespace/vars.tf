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
    volumeMounts = optional(object({
      volumes = list(any)
      mounts = list(object({
        mountPath = string
        name      = string
        subPath   = string
      }))
      }),
      {
        volumes = []
        mounts  = []
    })
  }))
}

variable "enable_gateway" {
  description = "Whether to create a gateway in the namespace or not"
  type        = bool
  default     = true
}

variable "domain_name" {}
variable "namespace" {}
variable "customer" {}
variable "common_env" {}
variable "docker_registry" {}
variable "istio_injection" {}
