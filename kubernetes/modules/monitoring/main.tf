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

locals {
  merged_alerts = concat(var.custom_alerts, var.required_alerts)
}

resource "random_password" "grafana" {
  length      = 16
  special     = false
  lower       = true
  min_lower   = 1
  numeric     = true
  min_numeric = 1
  upper       = true
  min_upper   = 1
}

resource "helm_release" "kube_prometheus_stack" {
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  name             = "prometheus"
  version          = var.kube_prometheus_stack_version
  namespace        = "monitoring"
  create_namespace = true

  values = [
    templatefile("${path.module}/configs/config.yaml", {
      prometheus_volume_size = var.prometheus_volume_size
      grafana_volume_size    = var.grafana_volume_size
      grafana_password       = random_password.grafana.result
      alerts = templatefile("${path.module}/configs/alerts.yaml", {
        custom_alerts = jsonencode(local.merged_alerts)
        #  prometheus_volume_size=var.prometheus_volume_size
        #  grafana_volume_size=var.grafana_volume_size
      })
      alertmanager = templatefile("${path.module}/configs/alertmanager.yaml", {
        slack_web_hook            = var.slack_web_hook
        slack_channel_name        = var.slack_channel_name
        pagerduty_key             = var.pagerduty_key
        alert_manager_volume_size = var.alert_manager_volume_size
        encoded_gchat_url         = "${var.gchat_lambda_url}${urlencode(var.gchat_webhook_url)}"
      })
    })
  ]
}

resource "helm_release" "prometheus_node_exporter" {
  name       = "node-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  namespace  = "monitoring"
  values = [
    templatefile("${path.module}/configs/nodeExporter.yaml", {
      image_version = var.node_exporter_version
    })
  ]
  cleanup_on_fail = true

  depends_on = [helm_release.kube_prometheus_stack]
}


resource "helm_release" "kube_state_metrics" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  namespace  = "monitoring"
  values = [
    templatefile("${path.module}/configs/kubeStateMetrics.yaml", {
      image_version = var.kube_state_metrics_version
    })
  ]
  atomic          = true
  cleanup_on_fail = true

  depends_on = [helm_release.kube_prometheus_stack]
}

resource "kubectl_manifest" "monitoring_gateway" {

  provider = kubectl.this

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
    - ${var.environment}-prometheus.${var.domain_name}
    - ${var.environment}-alertmanager.${var.domain_name}
    port:
      name: http
      number: 80
      protocol: HTTP
YAML

  depends_on = [helm_release.kube_prometheus_stack]
}

resource "kubectl_manifest" "kube_stack_virtualservices" {

  provider = kubectl.this

  for_each = {
    for pair in [
      for yaml in split(
        "\n---\n",
        "\n${replace(
          templatefile(
            "${path.module}/configs/virtualServices.yaml", {
              environment = var.environment
              domain_name = var.domain_name
          }), "/(?m)^---[[:blank:]]*(#.*)?$/", "---"
        )}\n"
      ) :
      [yamldecode(yaml), yaml]
      if trimspace(replace(yaml, "/(?m)(^[[:blank:]]*(#.*)?$)+/", "")) != ""
    ] : "${pair.0["kind"]}--${pair.0["metadata"]["name"]}" => pair.1
  }

  yaml_body = each.value

  depends_on = [helm_release.kube_prometheus_stack, kubectl_manifest.monitoring_gateway]
}

module "grafana_config" {
  source = "./modules/grafana-config"

  grafana_password = random_password.grafana.result
  vs_dependency    = kubectl_manifest.kube_stack_virtualservices

  environment       = var.environment
  domain_name       = var.domain_name
  grafana_role_arn  = var.grafana_role_arn
  configure_grafana = var.configure_grafana
}
