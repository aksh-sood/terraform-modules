# output "grafana_dev_password" {
#   description = "user password for grafana developer role"
#   value       = module.grafana_config.grafana_dev_password
# }

output "grafana_password" {
  description = "user password for grafana admin role"
  value       = random_password.password.result
}