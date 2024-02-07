terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubectl" {
  config_path = "~/.kube/${var.environment}"
}

data "template_file" "istio_logging_config" {
  template = file("${path.module}/istio_logging_config.yaml")

  vars = {
    opensearch_endpoint = var.opensearch_endpoint
    environment         = var.environment
    domain_name         = var.domain_name
  }
}

data "template_file" "init" {
  template = file("${path.module}/filebeat.yaml")
  vars = {
    OPENSEARCH_USERNAME = var.opensearch_username,
    OPENSEARCH_PASSWORD = var.opensearch_password
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "aws-es"
    namespace = "logging"
  }
  spec {
    external_name = var.opensearch_endpoint
    type          = "ExternalName"
    port {
      port        = 443
      target_port = 443
    }
  }

  depends_on = [kubernetes_namespace.logging, var.isito_dependency]
}

resource "helm_release" "filebeat" {
  name             = "filebeat"
  repository       = "https://helm.elastic.co/"
  chart            = "filebeat"
  version          = "7.13.0"
  namespace        = "logging"
  create_namespace = true

  values     = [data.template_file.init.rendered]
  depends_on = [kubernetes_service.proxy, kubernetes_namespace.logging, var.isito_dependency]
}

resource "kubectl_manifest" "gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: logging
  namespace: logging
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - ${var.environment}-kibana.${var.domain_name}
    port:
      name: http
      number: 80
      protocol: HTTP
YAML

  depends_on = [kubernetes_namespace.logging, var.isito_dependency]
}

resource "kubectl_manifest" "destination_rule" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: kibana
  namespace: logging
spec:
  host: ${var.opensearch_endpoint}
  trafficPolicy:
    tls:
      mode: SIMPLE
YAML

  depends_on = [kubernetes_namespace.logging, var.isito_dependency]
}

resource "kubectl_manifest" "service_entry" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: kibana
  namespace: logging
spec:
  hosts:
    - ${var.opensearch_endpoint}
  location: MESH_EXTERNAL
  ports:
    - number: 443
      name: https
      protocol: TLS
  resolution: DNS
YAML

  depends_on = [kubernetes_namespace.logging, var.isito_dependency]
}

resource "kubectl_manifest" "virtual_service" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: kibana
  namespace: logging
spec:
  gateways:
    - logging
  hosts:
    - ${var.environment}-kibana.${var.domain_name}
  http:
  - match:
    - uri:
        exact: "/"
    redirect:
      uri: "/_dashboards/"
      authority: ${var.environment}-kibana.${var.domain_name}
  - match:
    - uri:
        prefix: "/_dashboards/"
    route:
      - destination:
          host: ${var.opensearch_endpoint}
          port:
            number: 443
YAML

  depends_on = [kubernetes_namespace.logging, var.isito_dependency]
}