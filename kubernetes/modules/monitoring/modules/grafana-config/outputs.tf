output "grafana_dev_password" {
  description = "user password for grafana developer role"
  value       = random_string.dev_password.id
}
