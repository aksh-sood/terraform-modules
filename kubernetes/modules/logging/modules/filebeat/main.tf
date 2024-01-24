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
}

resource "helm_release" "filebeat" {
  name             = "filebeat"
  repository       = "https://helm.elastic.co/"
  chart            = "filebeat"
  version          = "7.13.0"
  namespace        = "logging"
  create_namespace = true

  values = [data.template_file.init.rendered]
  depends_on = [ kubernetes_service.proxy ]
}

resource "kubectl_manifest" "apply_manifest" {
  yaml_body = data.template_file.istio_logging_config.rendered
}