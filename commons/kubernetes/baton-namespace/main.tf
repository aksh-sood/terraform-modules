terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source                = "gavinbunney/kubectl"
      version               = ">= 1.7.0"
      configuration_aliases = [kubectl.this]
    }
  }
}

resource "kubernetes_namespace_v1" "application" {
  metadata {
    name = var.namespace
    labels = {
      istio-injection = var.istio_injection ? "enabled" : "disabled"
    }
  }
}

module "baton_application" {
  source   = "../baton-application"
  for_each = { for svc in var.services : svc.name => svc }

  namespace        = kubernetes_namespace_v1.application.metadata[0].name
  domain_name      = var.domain_name
  customer         = var.customer
  docker_registry  = var.docker_registry
  name             = each.value.name
  health_endpoint  = each.value.health_endpoint
  url_prefix       = each.value.url_prefix
  port             = each.value.port
  target_port      = each.value.target_port
  subdomain_suffix = each.value.subdomain_suffix
  image_tag        = each.value.image_tag
  volumes          = each.value.volumeMounts.volumes
  mounts           = each.value.volumeMounts.mounts
  security_context = each.value.security_context
  env = merge(each.value.env, var.common_env,
    {
      "APP_ENVIRONMENT"        = var.customer,
      "SPRING_PROFILES_ACTIVE" = var.namespace
    }
  )


}

module "activemq" {
  source = "../activemq"
  count  = var.enable_activemq ? 1 : 0

  domain_name       = var.domain_name
  namespace         = var.namespace
  activemq_username = var.activemq_username

  providers = {
    kubectl.this = kubectl.this
  }
}

resource "kubectl_manifest" "gateway" {

  provider = kubectl.this

  count = length(var.services) > 0 && var.enable_gateway ? 1 : 0

  yaml_body = templatefile("${path.module}/templates/gateway.yaml", {
    namespace = var.namespace,
    hosts = jsonencode(toset(concat([
      for app in module.baton_application : app.host
    ], var.enable_activemq ? module.activemq[0].url : [])))
  })

  depends_on = [kubernetes_namespace_v1.application]
}