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

resource "kubernetes_namespace" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
}

resource "kubernetes_service" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = "rabbitmq"
  }
  spec {
    external_name = var.rabbitmq_endpoint
    type          = "ExternalName"
    port {
      port        = 443
      target_port = 443
    }
  }

  depends_on = [kubernetes_namespace.rabbitmq]
}


resource "kubectl_manifest" "gateway" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: rabbitmq
  namespace: rabbitmq
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - ${var.name}-rabbitmq.${var.domain_name}
    port:
      name: http
      number: 80
      protocol: HTTP
YAML

  depends_on = [kubernetes_namespace.rabbitmq]
}

resource "kubectl_manifest" "destination_rule" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: rabbitmq
  namespace: rabbitmq
spec:
  host: ${var.rabbitmq_endpoint}
  trafficPolicy:
    tls:
      mode: SIMPLE
YAML

  depends_on = [kubernetes_namespace.rabbitmq]
}


resource "kubectl_manifest" "service_entry" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: rabbitmq
  namespace: rabbitmq
spec:
  hosts:
    - ${var.rabbitmq_endpoint}
  location: MESH_EXTERNAL
  ports:
    - number: 443
      name: https
      protocol: TLS
  resolution: DNS
YAML

  depends_on = [kubernetes_namespace.rabbitmq]
}


resource "kubectl_manifest" "virtual_service" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: rabbitmq
  namespace: rabbitmq
spec:
  gateways:
    - rabbitmq
  hosts:
    - ${var.name}-rabbitmq.${var.domain_name}
  http:
  - match:
    - uri:
        prefix: "/"
    route:
      - destination:
          host: ${var.rabbitmq_endpoint}
          port:
            number: 443
YAML

  depends_on = [kubernetes_namespace.rabbitmq]
}