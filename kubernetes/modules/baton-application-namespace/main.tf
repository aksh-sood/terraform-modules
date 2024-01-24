terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "kubectl" {
  config_path = "~/.kube/${var.environment}"
}

locals {
  hosts = [
    for ns in var.baton_application_namespaces : {
      namespace = ns.namespace
      hosts     = jsonencode([ for service in ns.services : "${var.environment}-${service.name}.${var.domain_name}" ])
    }
  ]
  services = flatten([
    for ns in var.baton_application_namespaces :
    [
      for service in ns.services :
      {
        namespace       = ns.namespace
        name            = service.name
        customer        = service.customer
        health_endpoint = service.health_endpoint
        target_port     = service.target_port
        endpoint        = service.endpoint
        url_prefix      = service.url_prefix
        env = merge(service.env,
        
          {"APP_ENVIRONMENT"=service.customer,"SPRING_PROFILES_ACTIVE"=ns.namespace}
        
        )
      }
    ]
  ])
}

resource "kubernetes_namespace_v1" "application" {
  for_each ={ for ns in var.baton_application_namespaces : ns.namespace => ns }
  metadata {
    name = each.value.namespace
    labels = {
      istio_injection = each.value.istio_injection?"enabled":"disabled"
    }
  }
}

resource "kubectl_manifest" "gateways" {
  for_each ={ for ns in local.hosts : ns.namespace => ns }
  yaml_body = templatefile("${path.module}/gateway.yaml",{
    namespace=each.value.namespace,
    hosts=each.value.hosts
  })

  depends_on = [kubernetes_namespace_v1.application]
}






resource "helm_release" "baton-application" {
  for_each ={ for svc in local.services : svc.name => svc }
    name = each.value.name
    namespace = each.value.namespace
    chart = "${path.module}/baton-service"
  values = [ 
<<-EOT
customer: ${each.value.customer}
health_endpoint: ${each.value.health_endpoint}
targetPort: ${each.value.target_port}
endpoint: ${each.value.endpoint}
url_prefix: ${each.value.url_prefix}
domain: ${var.domain_name}
env: ${jsonencode(each.value.env)}
EOT
  ]

}
