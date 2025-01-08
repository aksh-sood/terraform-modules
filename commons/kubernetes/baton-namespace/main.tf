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

resource "kubernetes_config_map" "env" {

  metadata {
    name      = "env-config"
    namespace = kubernetes_namespace_v1.application.metadata[0].name
  }

  data = local.env_config_map
}


module "baton_application" {
  source   = "../baton-application"
  for_each = { for k, v in var.services : k => v }

  namespace            = kubernetes_namespace_v1.application.metadata[0].name
  domain_name          = var.domain_name
  customer             = var.customer
  docker_registry      = var.docker_registry
  name                 = each.key
  health_endpoint      = each.value.health_endpoint
  url_prefix           = each.value.url_prefix
  port                 = each.value.port
  target_port          = each.value.target_port
  replicas             = each.value.replicas
  subdomain_suffix     = each.value.subdomain_suffix
  image_tag            = each.value.image_tag
  command              = each.value.command
  node_selectors       = each.value.node_selectors
  security_context     = each.value.security_context
  config_map           = each.value.config_map
  config_map_file_path = each.value.config_map_file_path
  volumes              = concat(each.value.volumeMounts.volumes, local.env_cm.volume)
  mounts               = concat(each.value.volumeMounts.mounts, local.env_cm.mount)
  env = merge({
    "APP_ENVIRONMENT"        = var.customer,
    "SPRING_PROFILES_ACTIVE" = var.namespace
    },
    each.value.env, var.common_env
  )

  depends_on = [kubernetes_config_map.env]
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