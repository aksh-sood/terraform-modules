data "template_file" "init" {
  template = file("${path.module}/filebeat.yaml")
  vars = {
    OPENSEARCH_USERNAME = var.opensearch_username,
    OPENSEARCH_PASSWORD = var.opensearch_password
  }
}

resource "kubernetes_service" "example" {
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
}

resource "helm_release" "filebeat" {
  name             = "filebeat"
  repository       = "https://helm.elastic.co/"
  chart            = "filebeat"
  version          = "7.13.0"
  namespace        = "logging"
  create_namespace = true


  values = [data.template_file.init.rendered]
}

resource "kubernetes_manifest" "gateway_logging_logging" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "Gateway"
    "metadata" = {
      "name"      = "logging"
      "namespace" = "logging"
    }
    "spec" = {
      "selector" = {
        "istio" = "ingressgateway"
      }
      "servers" = [
        {
          "hosts" = [
            "test-kibana.batonsystems.com",
          ]
          "port" = {
            "name"     = "http"
            "number"   = 80
            "protocol" = "HTTP"
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "virtualservice_logging_kibana" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "VirtualService"
    "metadata" = {
      "name"      = "kibana"
      "namespace" = "logging"
    }
    "spec" = {
      "gateways" = [
        "logging",
      ]
      "hosts" = [
        "${var.environment_name}-kibana.batonsystems.com",
      ]
      "http" = [
        {
          "match" = [
            {
              "uri" = {
                "exact" = "/"
              }
            },
          ]
          "redirect" = {
            "authority" = "${var.environment_name}-kibana.batonsystems.com"
            "uri"       = "/_dashboards/"
          }
        },
        {
          "match" = [
            {
              "uri" = {
                "prefix" = "/_dashboards/"
              }
            },
          ]
          "route" = [
            {
              "destination" = {
                "host" = var.opensearch_endpoint
                "port" = {
                  "number" = 443
                }
              }
            },
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "serviceentry_logging_kibana" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ServiceEntry"
    "metadata" = {
      "name"      = "kibana"
      "namespace" = "logging"
    }
    "spec" = {
      "hosts" = [
        var.opensearch_endpoint,
      ]
      "location" = "MESH_EXTERNAL"
      "ports" = [
        {
          "name"     = "https"
          "number"   = 443
          "protocol" = "TLS"
        },
      ]
      "resolution" = "DNS"
    }
  }
}

resource "kubernetes_manifest" "destinationrule_logging_kibana" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "DestinationRule"
    "metadata" = {
      "name"      = "kibana"
      "namespace" = "logging"
    }
    "spec" = {
      "host" = var.opensearch_endpoint
      "trafficPolicy" = {
        "tls" = {
          "mode" = "SIMPLE"
        }
      }
    }
  }
}