resource "helm_release" "baton-application" {
  name      = var.name
  namespace = var.namespace
  chart     = "${path.module}/baton-service"
  wait      = false

  values = [
    <<-EOT
docker_registry: ${var.docker_registry}
customer: ${var.customer}
health_endpoint: ${var.health_endpoint}
targetPort: ${var.target_port}
subdomain_suffix: ${var.subdomain_suffix}
url_prefix: ${var.url_prefix}
domain: ${var.domain_name}
image_tag: ${var.image_tag}
mounts: ${jsonencode(var.mounts)}
volumes: ${jsonencode(var.volumes)}
env: ${jsonencode(var.env)}
EOT
  ]
}
