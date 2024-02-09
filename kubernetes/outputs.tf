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

# output "grafana_developer_username" {
#   description = "username for grafana developer role"
#   value       = "developer"
#   sensitive   = true
# }

# output "grafana_developer_password" {
#   description = "user password for grafana developer role"
#   value       = module.monitoring.grafana_dev_password
#   sensitive   = true
# }

output "loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = module.istio.loadbalancer_url
}
