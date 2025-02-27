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

data "template_file" "init" {
  template = file("${path.module}/filebeat.yaml")
  vars = {
    OPENSEARCH_USERNAME = var.opensearch_username,
    OPENSEARCH_PASSWORD = var.opensearch_password
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "aws-es"
    namespace = var.namespace
  }
  spec {
    external_name = var.opensearch_endpoint
    type          = "ExternalName"
    port {
      port        = 443
      target_port = 443
    }
  }
}

resource "helm_release" "filebeat" {
  name             = "filebeat"
  repository       = "https://helm.elastic.co/"
  chart            = "filebeat"
  version          = "7.13.0"
  namespace        = var.namespace
  create_namespace = false

  values     = [data.template_file.init.rendered]
  depends_on = [kubernetes_service.proxy]
}

resource "kubectl_manifest" "gateway" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: logging
  namespace: ${var.namespace}
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
}

resource "kubectl_manifest" "destination_rule" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: kibana
  namespace: ${var.namespace}
spec:
  host: ${var.opensearch_endpoint}
  trafficPolicy:
    tls:
      mode: SIMPLE
YAML
}

resource "kubectl_manifest" "service_entry" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: kibana
  namespace: ${var.namespace}
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
}

resource "kubectl_manifest" "virtual_service" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: kibana
  namespace: ${var.namespace}
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
}
