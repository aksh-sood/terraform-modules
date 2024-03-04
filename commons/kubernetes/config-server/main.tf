data "aws_secretsmanager_secret" "this" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

module "config_server_deployment" {
  source = "../baton-namespace"

  domain_name     = var.domain_name
  namespace       = var.config_server.namespace
  enable_gateway  = var.config_server.enable_gateway
  istio_injection = var.config_server.istio_injection
  customer        = var.config_server.customer
  services        = [var.config_server.service]
  common_env      = var.config_server.common_env
  volumeMounts    = var.config_server.volumeMounts

  providers = {
    kubectl.this = kubectl.this
  }
}

resource "kubernetes_config_map_v1" "this" {
    metadata {
    name = "ssh-key"
    namespace = var.config_server.namespace
  }
  data = {
    id_rsa=jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["${var.ssh_secret_key}"]
  }
}
