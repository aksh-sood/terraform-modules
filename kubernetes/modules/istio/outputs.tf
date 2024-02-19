output "loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = kubernetes_ingress_v1.alb_ingress.status.0.load_balancer.0.ingress.0.hostname
}

output "prometheus_password" {
  value     = random_password.password[0].result
  sensitive = true
}

output "alertmanager_password" {
  value     = random_password.password[1].result
  sensitive = true
}

output "jaeger_password" {
  value     = random_password.password[2].result
  sensitive = true
}