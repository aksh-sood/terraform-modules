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

locals {
# A new map is generated containing the namespace and host names which are 
# extracted in the below code for creating gateways
  gateways = [for gate in [
    for ns in var.baton_application_namespaces : length(ns.services) > 0 ? {
      namespace = ns.namespace
      hosts = jsonencode([
        for service in ns.services : service.subdomain_suffix == "" ?
        "${var.environment}.${var.domain_name}"
        :
      "${var.environment}-${service.subdomain_suffix}.${var.domain_name}"])
    } : null
  ] : gate if gate != null]

# A list of all the services is created with there 
# namespace , customer , common environment variables appended to each sservice for helm chart.
  services = flatten([
    for ns in var.baton_application_namespaces :
    [
      for service in ns.services :
      {
        namespace        = ns.namespace
        customer         = ns.customer
        name             = service.name
        health_endpoint  = service.health_endpoint
        target_port      = service.target_port
        subdomain_suffix = service.subdomain_suffix == "" ? "" : "-${service.subdomain_suffix}"
        url_prefix       = service.url_prefix
        image_tag        = service.image_tag
        env = merge(service.env, ns.common_env, var.common_connections,

          {
            "APP_ENVIRONMENT"        = ns.customer,
            "SPRING_PROFILES_ACTIVE" = ns.namespace
          }
        )
      }
    ]
  ])
}

resource "kubernetes_namespace_v1" "application" {
  for_each = { for ns in var.baton_application_namespaces : ns.namespace => ns }
  metadata {
    name = each.value.namespace
    labels = {
      istio-injection = each.value.istio_injection ? "enabled" : "disabled"
    }
  }
}

resource "kubectl_manifest" "gateways" {

  provider = kubectl.this

  for_each = { for ns in local.gateways : ns.namespace => ns }
  yaml_body = templatefile("${path.module}/templates/gateway.yaml", {
    namespace = each.value.namespace,
    hosts     = each.value.hosts
  })

  depends_on = [kubernetes_namespace_v1.application]
}

resource "helm_release" "baton-application" {
  for_each = { for svc in local.services : svc.name => svc }

  name      = each.value.name
  namespace = each.value.namespace
  chart     = "${path.module}/baton-service"
  wait      = false

  values = [
    <<-EOT
customer: ${each.value.customer}
health_endpoint: ${each.value.health_endpoint}
targetPort: ${each.value.target_port}
subdomain_suffix: ${each.value.subdomain_suffix}
url_prefix: ${each.value.url_prefix}
domain: ${var.domain_name}
image_tag: ${each.value.image_tag}
env: ${jsonencode(each.value.env)}
EOT
  ]
}
