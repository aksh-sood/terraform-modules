output "loadbalancer_url" {
  description = "Hostname for the istio ingress created"
  value       = kubernetes_ingress_v1.alb_ingress.status.0.load_balancer.0.ingress.0.hostname
}