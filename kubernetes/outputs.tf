output "grafana_dev_password" {
  description = "user password for grafana developer role"
  value       = module.monitoring.grafana_dev_password
}

output "grafana_password" {
  description = "user password for grafana admin role"
  value       = module.monitoring.grafana_password
}