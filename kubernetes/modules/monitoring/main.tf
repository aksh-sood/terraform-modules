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

resource "random_string" "grafana_password" {
  length  = 10
  special = true
}

resource "helm_release" "kube_prometheus_stack" {
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  name             = "prometheus"
  version          = var.kube_prometheus_stack_version
  namespace        = "monitoring"
  create_namespace = true

  values = [
    templatefile("${path.module}/config.yaml", {
      prometheus_volume_size = var.prometheus_volume_size
      grafana_volume_size    = var.grafana_volume_size
      grafana_password       = random_string.grafana_password.id
      alerts = templatefile("${path.module}/alerts.yaml", {
        custom_alerts = jsonencode(var.custom_alerts)
        #  prometheus_volume_size=var.prometheus_volume_size
        #  grafana_volume_size=var.grafana_volume_size 
      })
      alertmanager = templatefile("${path.module}/alertmanager.yaml", {
        slack_web_hook            = var.slack_web_hook
        slack_channel_name        = var.slack_channel_name
        pagerduty_key             = var.pagerduty_key
        alert_manager_volume_size = var.alert_manager_volume_size
      })
    })
  ]
}

resource "kubectl_manifest" "monitoring_gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: monitoring-gateway
  namespace: monitoring
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - ${var.environment}-grafana.${var.domain_name}
    port:
      name: http
      number: 80
      protocol: HTTP
YAML

  depends_on = [var.isito_dependency]
}

resource "kubectl_manifest" "grafana_virtualservice" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: grafana
  namespace: monitoring
spec:
  gateways:
  - monitoring-gateway
  - mesh
  hosts:
  - ${var.environment}-grafana.${var.domain_name}
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: grafana
        port:
          number: 80
YAML

  depends_on = [var.isito_dependency]
}

module "grafana_config" {
  source = "./modules/grafana-config"

  grafana_password = random_string.grafana_password.id
  dependency       = helm_release.kube_prometheus_stack
  grafana_role_arn = var.grafana_role_arn
}