output "sftp_password" {
  description = "password for SDTP server"
  value = random_password.password.result
}

output "sftp_username" {
  description = "username for the SFTP server"
  value = var.sftp_username
}

output "host" {
  description = "SFTP hostname"
  value = "sftp.${kubernetes_namespace_v1.this.metadata.0.name}"
}