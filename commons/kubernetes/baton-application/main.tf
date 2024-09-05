resource "kubernetes_config_map" "app" {

  metadata {
    name      = var.name
    namespace = var.namespace
  }

  data = local.config_map
}

resource "helm_release" "baton-application" {
  name      = var.name
  namespace = var.namespace
  chart     = "${path.module}/baton-service"
  wait      = false

  values = [
    <<-EOT
docker_registry: ${var.docker_registry}
replicas: ${var.replicas}
customer: ${var.customer}
health_endpoint: ${var.health_endpoint}
port: ${var.port}
targetPort: ${var.target_port}
subdomain_suffix: ${var.subdomain_suffix}
url_prefix: ${var.url_prefix}
domain: ${var.domain_name}
image_tag: ${var.image_tag}
security_context: ${var.security_context}
env: ${jsonencode(var.env)}
command: ${jsonencode(var.command)}
volumes: ${jsonencode(concat(var.volumes, local.app_cm.volume))}
mounts: ${jsonencode(concat(var.mounts, local.app_cm.mount))}
EOT
  ]

  depends_on = [kubernetes_config_map.app]
}
