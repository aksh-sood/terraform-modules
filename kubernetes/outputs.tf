output "grafana_admin_username" {
  description = "username for grafana admin role"
  value       = "admin"
  sensitive   = true
}

output "grafana_admin_password" {
  description = "user password for grafana admin role"
  value       = module.monitoring.grafana_password
  sensitive   = true
}

output "grafana_developer_username" {
  description = "username for grafana developer role"
  value       = "developer"
  sensitive   = true
}

output "grafana_developer_password" {
  description = "user password for grafana developer role"
  value       = module.monitoring.grafana_dev_password
  sensitive   = true
}

output "external_loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = module.istio.external_loadbalancer_url
}

output "internal_loadbalancer_url" {
  description = "Hostname for the private istio ingress created"
  value       = module.istio.internal_loadbalancer_url
}

output "jaeger_username" {
  value = "admin"
}

output "jaeger_password" {
  value     = module.istio.jaeger_password
  sensitive = true
}

output "alertmanager_username" {
  value = "admin"
}

output "alertmanager_password" {
  value     = module.istio.alertmanager_password
  sensitive = true
}

output "prometheus_username" {
  value = "admin"
}

output "prometheus_password" {
  value     = module.istio.prometheus_password
  sensitive = true
}

output "sftp_password" {
  description = "password for sftp user"
  value       = var.enable_sftp ? module.sftp[0].sftp_password : null
  sensitive   = true
}

output "sftp_username" {
  description = "username for the SFTP server"
  value       = var.enable_sftp ? module.sftp[0].sftp_username : null
}

output "sftp_host" {
  description = "SFTP hostname"
  value       = var.enable_sftp ? module.sftp[0].host : null
}

output "app_password" {
  description = "Basic Auth password for metrics endpoint of the application"
  value       = module.istio.app_password
  sensitive   = true
}
