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

data "aws_secretsmanager_secret" "this" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

module "config_server_deployment" {
  source = "../../../commons/kubernetes/baton-namespace"

  domain_name     = local.domain_name
  namespace       = local.config_server.namespace
  docker_registry = local.config_server.docker_registry
  enable_gateway  = local.config_server.enable_gateway
  istio_injection = local.config_server.istio_injection
  customer        = local.config_server.customer
  common_env      = local.config_server.common_env
  services        = [local.config_server.service]

  providers = {
    kubectl.this = kubectl.this
  }
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = "ssh-key"
    namespace = local.config_server.namespace
  }
  data = {
    id_rsa = data.aws_secretsmanager_secret_version.this.secret_string
  }
}
