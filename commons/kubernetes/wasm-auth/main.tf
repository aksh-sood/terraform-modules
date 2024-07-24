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

resource "random_password" "password" {
  length           = 10
  special          = false
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
  name: basic-auth-app
  namespace: istio-system
spec:
  phase: AUTHN
  pluginConfig:
    basic_auth_rules:
    - credentials:
      - ${base64encode("admin:${random_password.password.result}")}
      hosts:
      - '*.${var.domain_name}'
      suffix: /metrics
      request_methods:
      - GET
      - POST
  selector:
    matchLabels:
      istio: ingressgateway
  url: oci://ghcr.io/istio-ecosystem/wasm-extensions/basic_auth:1.12.0
YAML

}
