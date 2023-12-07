module "addons" {
  source = "./modules/addons"

  cluster_name      = var.environment
  lbc_addon_version = var.lbc_addon_version
  efs_addon_version = var.efs_addon_version
  efs_id            = var.efs_id

}

module "istio" {
  source = "./modules/istio"

  acm_certificate_arn    = var.acm_certificate_arn
  istio_version          = var.istio_version
  siem_storage_s3_bucket = var.siem_storage_s3_bucket

  depends_on = [module.addons]
}

module "monitoring" {
  source = "./modules/monitoring"

  slack_channel_name            = var.slack_channel_name
  kube_prometheus_stack_version = var.kube_prometheus_stack_version
  slack_web_hook                = var.slack_web_hook
  pagerduty_key                 = var.pagerduty_key
  custom_alerts                 = var.custom_alerts
  alert_manager_volume_size     = var.alert_manager_volume_size
  prometheus_volume_size        = var.prometheus_volume_size
  grafana_role_arn              = var.grafana_role_arn
}