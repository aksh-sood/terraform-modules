output "sftp_user_password" {
  description = "password for sftp user"
  value = random_password.password.result
}