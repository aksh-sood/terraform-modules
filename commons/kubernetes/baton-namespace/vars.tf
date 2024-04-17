variable "services" {
  description = "List of services and there required attributes"
  type = list(object({
    name             = string
    health_endpoint  = string
    target_port      = number
    url_prefix       = string
    env              = map(string)
    port             = optional(number, 8080)
    subdomain_suffix = optional(string, "")
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

variable "enable_activemq" {
  description = "Whether to enable activemq inside the namespace"
  type        = bool
  default     = false
}

variable "activemq_username" {
  type    = string
  default = "admin"
}

variable "namespace" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "docker_registry" {
  type    = string
  default = "150399859526.dkr.ecr.us-west-2.amazonaws.com"
}

variable "istio_injection" {
  type    = bool
  default = true
}

variable "customer" {
  type = string
}

variable "common_env" {}
