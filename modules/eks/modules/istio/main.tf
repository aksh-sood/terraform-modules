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
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "deletion_protection.enabled=true,access_logs.s3.enabled=true,access_logs.s3.bucket=${var.siem_storage_s3_bucket}"
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

  depends_on = [helm_release.istio_ingress]
}