module "addons" {
  source = "./modules/addons"

  cluster_name      = var.environment
  lbc_addon_version = var.lbc_addon_version
}

module "cloudflare" {
  source = "./modules/cloudflare"
  count  = var.create_dns_records ? 1 : 0

  loadbalancer_url = module.istio.loadbalancer_url
  environment      = var.environment
  domain_name      = var.domain_name

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
    directoryPerms   = "700"
  }

  depends_on = [module.addons]
}

module "istio" {
  source = "./modules/istio"

  enable_siem            = var.enable_siem
  acm_certificate_arn    = var.acm_certificate_arn
  istio_version          = var.istio_version
  siem_storage_s3_bucket = var.siem_storage_s3_bucket

  depends_on = [module.addons]
}

module "monitoring" {
  source = "./modules/monitoring"

  isito_dependency = module.istio

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