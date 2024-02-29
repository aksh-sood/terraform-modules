locals {
  cnames = toset(["prometheus", "grafana", "alertmanager", "kibana", "jaeger"])
}

resource "null_resource" "config_server_validation" {
  lifecycle {
    precondition {
      condition = var.enable_config_server ? (
      var.bitbucket_key_secrets_manager_name != "" && var.bitbucket_key_secrets_manager_name != null && var.config_repo_url != "" && var.config_repo_url != null) : true
      error_message = "Provide secret_name and config_repo_url or set enable_config_server to false"
    }
  }
}

module "addons" {
  source = "./modules/addons"

  cluster_name      = var.environment
  lbc_addon_version = var.lbc_addon_version
}

module "cloudflare" {
  source = "../commons/utilities/cloudflare"
  count  = var.create_dns_records ? 1 : 0

  loadbalancer_url = module.istio.loadbalancer_url

  cnames      = local.cnames
  name        = var.environment
  domain_name = var.domain_name

  providers = {
    cloudflare.this = cloudflare.this
  }

}

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = "${var.efs_id}"
    directoryPerms   = "777"
    uid              = 0
    gid              = 0
  }

  depends_on = [module.addons]
}

module "istio" {
  source = "./modules/istio"

  enable_siem            = var.enable_siem
  environment            = var.environment
  domain_name            = var.domain_name
  acm_certificate_arn    = var.acm_certificate_arn
  istio_version          = var.istio_version
  siem_storage_s3_bucket = var.siem_storage_s3_bucket

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.addons]
}

module "monitoring" {
  source = "./modules/monitoring"

  isito_dependency = module.istio

  configure_grafana             = var.create_dns_records
  environment                   = var.environment
  domain_name                   = var.domain_name
  slack_channel_name            = var.slack_channel_name
  kube_prometheus_stack_version = var.kube_prometheus_stack_version
  slack_web_hook                = var.slack_web_hook
  pagerduty_key                 = var.pagerduty_key
  custom_alerts                 = var.custom_alerts
  alert_manager_volume_size     = var.alert_manager_volume_size
  prometheus_volume_size        = var.prometheus_volume_size
  grafana_role_arn              = var.grafana_role_arn

  providers = {
    kubectl.this = kubectl.this
  }

}

module "logging" {
  source = "./modules/logging"

  environment         = var.environment
  opensearch_endpoint = var.opensearch_endpoint
  opensearch_password = var.opensearch_password
  opensearch_username = var.opensearch_username
  domain_name         = var.domain_name

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.istio]
}

module "jaeger" {
  source = "./modules/jaeger"

  environment   = var.environment
  istio_version = var.istio_version
  domain_name   = var.domain_name

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.istio]
}

module "config_server" {
  source = "./modules/config-server"
  count  = var.enable_config_server ? 1 : 0

  secret_name             = var.bitbucket_key_secrets_manager_name
  config_repo_url         = var.config_repo_url
  image_tag               = var.config_server_image_tag

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.istio, null_resource.config_server_validation]
}

module "sftp" {
  source = "./modules/sftp"
  count  = var.enable_sftp ? 1 : 0

  storage_class_name = kubernetes_storage_class_v1.efs.metadata.0.name

  namespace     = var.sftp_namespace
  sftp_username = var.sftp_username
}