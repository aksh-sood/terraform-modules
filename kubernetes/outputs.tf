output "grafana_dev_password" {
  description = "user password for grafana developer role"
  value       = module.monitoring.grafana_dev_password
  sensitive   = true
}

output "grafana_password" {
  description = "user password for grafana admin role"
  value       = module.monitoring.grafana_password
  sensitive   = true
}

output "loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = module.istio.loadbalancer_url
}