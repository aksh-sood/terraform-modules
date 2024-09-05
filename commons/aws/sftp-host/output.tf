output "eip" {
  value = aws_eip.sftp_proxy.public_ip
}

output "sftp_rsa" {
  value     = trimspace(tls_private_key.ssh_key.private_key_pem)
  sensitive = true
}

output "sftp_pub" {
  value     = trimspace(tls_private_key.ssh_key.public_key_openssh)
  sensitive = true
}