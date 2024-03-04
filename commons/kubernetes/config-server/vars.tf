variable "secret_name" {
  description = "Name of the secret storing ssh key to configure into config map of config server"
  type = string
}

variable "ssh_secret_key" {
  description = "key in secret storing the SSH file"
  type = string
}

variable "config_server" {
  type = object({
    namespace       = string
    customer        = string
    istio_injection = bool
    enable_gateway  = optional(bool, false)
    common_env      = optional(map(string), {})
    service = object({
      name             = string
      health_endpoint  = optional(string, "/health")
      target_port      = number
      subdomain_suffix = optional(string, "")
      url_prefix       = string
      env              = optional(map(string), {})
      image_tag        = optional(string, "latest")
    })
    volumeMounts   = optional(object({
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
    }),
    {
      volumes=[]
      mounts=[]
    })
  })
}

variable "region" {}
variable "domain_name" {}
variable "environment" {}