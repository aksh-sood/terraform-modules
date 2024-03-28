variable "namespace" {
  description = "namespace to deploy sftp server"
  type = string
  default = "sftp"
}

variable "storage_class_name" {
  description = "Name of the storage class to associate persistent volumes and claims"
  type = string
}

variable "sftp_username" {
  description = "username for SFTP server"
  type = string
  default = "myuser"
}