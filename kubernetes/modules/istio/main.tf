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

# Istio helm installation
resource "helm_release" "istio_base" {
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  name             = "istio-base"
  namespace        = "istio-system"
  create_namespace = true
  version          = var.istio_version

  set {
    name  = "defaultRevision"
    value = "default"
  }
}

resource "helm_release" "istiod" {
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  name             = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = var.istio_version

  depends_on = [helm_release.istio_base]

}

resource "helm_release" "istio_ingress" {
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "gateway"
  name            = "istio-ingressgateway"
  version         = var.istio_version
  cleanup_on_fail = true
  namespace       = "istio-system"

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.ports[0].name"
    value = "status-port"
  }
  set {
    name  = "service.ports[0].port"
    value = "15021"
  }
  set {
    name  = "service.ports[0].protocol"
    value = "TCP"
  }
  set {
    name  = "service.ports[0].targetPort"
    value = "15021"
  }

  set {
    name  = "service.ports[1].name"
    value = "http2"
  }
  set {
    name  = "service.ports[1].port"
    value = "80"
  }
  set {
    name  = "service.ports[1].protocol"
    value = "TCP"
  }
  set {
    name  = "service.ports[1].targetPort"
    value = "80"
  }

  set {
    name  = "service.ports[2].name"
    value = "https"
  }
  set {
    name  = "service.ports[2].port"
    value = "443"
  }
  set {
    name  = "service.ports[2].protocol"
    value = "TCP"
  }
  set {
    name  = "service.ports[2].targetPort"
    value = "80"
  }

  depends_on = [helm_release.istiod]
}

resource "kubernetes_ingress_v1" "alb_ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "istio-alb"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz/ready"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.acm_certificate_arn
      "alb.ingress.kubernetes.io/ssl-policy"           = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      "alb.ingress.kubernetes.io/success-codes"        = "404"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      # The flow logging for the ELB cannot work if the native region of the bucket does not match that is the ELB
      "alb.ingress.kubernetes.io/load-balancer-attributes" = var.enable_siem ? join("", [var.alb_base_attributes, ",access_logs.s3.enabled=true,access_logs.s3.bucket=${var.siem_storage_s3_bucket}"]) : var.alb_base_attributes
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }

        }

        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "istio-ingressgateway"
              port {
                number = 443
              }
            }
          }

        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.enable_siem ? (var.siem_storage_s3_bucket != "" && var.siem_storage_s3_bucket != null) : true
      error_message = "Provided siem_storage_s3_bucket or disable enable_siem"
    }
  }

  depends_on = [helm_release.istio_ingress]
}

resource "kubectl_manifest" "istio_gateway" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: istio-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - ${var.environment}-jaeger.${var.domain_name}
    port:
      name: http
      number: 80
      protocol: HTTP
YAML

  depends_on = [helm_release.istio_ingress]
}

resource "random_password" "password" {
  count = 3

  length           = 16
  special          = true
  override_special = "!*=+?"
  min_special      = 1
  lower            = true
  min_lower        = 1
  numeric          = true
  min_numeric      = 1
  upper            = true
  min_upper        = 1
}

resource "kubectl_manifest" "basic_auth" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: extensions.istio.io/v1alpha1
kind: WasmPlugin
metadata:
  name: basic-auth
  namespace: istio-system
spec:
  phase: AUTHN
  pluginConfig:
    basic_auth_rules:
    - credentials:
      - ${base64encode("admin:${random_password.password[0].result}")}
      hosts:
      - ${var.environment}-prometheus.${var.domain_name}
      prefix: /
      request_methods:
      - GET
      - POST
    - credentials:
      - ${base64encode("admin:${random_password.password[1].result}")}
      hosts:
      - ${var.environment}-alertmanager.${var.domain_name}
      prefix: /
      request_methods:
      - GET
      - POST
    - credentials:
      - ${base64encode("admin:${random_password.password[2].result}")}
      hosts:
      - ${var.environment}-jaeger.${var.domain_name}
      prefix: /
      request_methods:
      - GET
      - POST
  selector:
    matchLabels:
      istio: ingressgateway
  url: oci://ghcr.io/istio-ecosystem/wasm-extensions/basic_auth:1.12.0
YAML

  depends_on = [helm_release.istio_ingress]
}