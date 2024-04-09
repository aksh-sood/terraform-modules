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

resource "kubernetes_manifest" "service" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "activemq"
      "namespace" = var.namespace
    }
    "spec" = {
      "ports" = [
        {
          "name"       = "tcp-service"
          "port"       = 61616
          "targetPort" = 61616
        },
        {
          "name"       = "tcp-stomp"
          "port"       = 61613
          "targetPort" = 61613
        },
        {
          "name"       = "http-web"
          "port"       = 8161
          "targetPort" = 8161
        },
      ]
      "selector" = {
        "app" = "activemq"
      }
      "type" = "NodePort"
    }
  }
}

resource "kubernetes_manifest" "service_account" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "activemq"
      "namespace" = var.namespace
    }
  }
}

resource "kubernetes_manifest" "deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "activemq-deployment"
      "namespace" = var.namespace
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "activemq"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "activemq"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name"  = "ACTIVEMQ_ADMIN_LOGIN"
                  "value" = var.activemq_username
                },
                {
                  "name"  = "ACTIVEMQ_ADMIN_PASSWORD"
                  "value" = var.activemq_password
                },
              ]
              "image" = "webcenter/activemq"
              "name"  = "activemq"
              "ports" = [
                {
                  "containerPort" = 2181
                },
                {
                  "containerPort" = 8161
                },
                {
                  "containerPort" = 61616
                },
              ]
            },
          ]
          "serviceAccountName" = "activemq"
        }
      }
    }
  }
}


resource "kubectl_manifest" "virtual_service" {

  provider = kubectl.this

  yaml_body = templatefile("${path.module}/templates/virtualservice.yaml", {
    namespace   = var.namespace,
    domain_name = var.domain_name
  })

}