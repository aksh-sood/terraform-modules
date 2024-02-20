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

output "loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = module.istio.loadbalancer_url
}

output "jaeger_username" {
  value     = "admin"
}

output "jaeger_password" {
  value     = module.istio.jaeger_password
  sensitive = true
}

output "alertmanager_username" {
  value     = "admin"
}

output "alertmanager_password" {
  value     = module.istio.alertmanager_password
  sensitive = true
}

output "prometheus_username" {
  value     = "admin"
}

output "prometheus_password" {
  value     = module.istio.prometheus_password
  sensitive = true
}

output "fqdn" {
  value = var.create_dns_records? module.cloudflare[0].domains:null
}