output "grafana_dev_password" {
  description = "user password for grafana developer role"
  value       = module.monitoring.grafana_dev_password
}

output "grafana_password" {
  description = "user password for grafana admin role"
  value       = module.monitoring.grafana_password
}

output "loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = module.istio.loadbalancer_url
}