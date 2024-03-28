variable "secret_name" {
  description = "Name of the secret storing ssh key to configure into config map of config server"
  type        = string
}

variable "config_repo_url" {
  description = "SSH link to config repo repository for configuring Env variables of applications"
  type = string
}

variable "config_server_image_tag" {
  description = "Version of the config-server to deploy"
  type = number
}