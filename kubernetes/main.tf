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

module "cluster_autoscaler" {
  source = "./modules/cluster-autoscaler"
  count  = var.enable_cluster_autoscaler ? 1 : 0

  cluster_name       = var.environment
  controller_version = var.cluster_autoscaler_version
}

module "cloudflare" {
  source = "../commons/utilities/cloudflare"
  count  = var.create_dns_records ? 1 : 0

  loadbalancer_url = module.istio.internal_loadbalancer_url

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

  enable_siem                 = var.enable_siem
  environment                 = var.environment
  domain_name                 = var.domain_name
  acm_certificate_arn         = var.acm_certificate_arn
  istio_version               = var.istio_version
  siem_storage_s3_bucket      = var.siem_storage_s3_bucket
  security_group              = var.elb_security_group
  internal_alb_security_group = var.internal_alb_security_group
  waf_arn                     = var.waf_arn

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.addons]
}

module "gchat_lambda" {
  source                    = "../commons/aws/gchat-lambda"
  count                     = var.gchat_webhook != null ? 1 : 0

  slack_webhook_url         = ""
  name                      = var.environment
  environment               = var.environment
  region                    = var.region
  gchat_webhook_url         = var.gchat_webhook
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  package_key               = "gchat-lambda.zip"
  tags                      = var.cost_tags
}

module "monitoring" {
  source = "./modules/monitoring"


  gchat_lambda_url = var.gchat_webhook != null ? module.gchat_lambda[0].url : null

  configure_grafana             = var.create_dns_records
  environment                   = var.environment
  domain_name                   = var.domain_name
  slack_channel_name            = var.slack_channel_name
  kube_prometheus_stack_version = var.kube_prometheus_stack_version
  node_exporter_version         = var.node_exporter_version
  kube_state_metrics_version    = var.kube_state_metrics_version
  slack_web_hook                = var.slack_web_hook
  gchat_webhook_url             = var.gchat_webhook
  pagerduty_key                 = var.pagerduty_key
  custom_alerts                 = var.prometheus_custom_alerts
  alert_manager_volume_size     = var.alert_manager_volume_size
  prometheus_volume_size        = var.prometheus_volume_size
  grafana_role_arn              = var.grafana_role_arn

  providers = {
    kubectl.this = kubectl.this
  }

}

module "logging" {
  source = "./modules/logging"

  region                      = var.region
  vendor                      = var.vendor
  dependency                  = module.istio
  environment                 = var.environment
  domain_name                 = var.domain_name
  s3_bucket_for_curator       = var.s3_bucket_for_curator
  opensearch_endpoint         = var.opensearch_endpoint
  opensearch_password         = var.opensearch_password
  opensearch_username         = var.opensearch_username
  curator_image_tag           = var.curator_image_tag
  curator_iam_role_arn        = var.curator_iam_role_arn
  curator_iam_user_arn        = var.curator_iam_user_arn
  curator_iam_user_access_key = var.curator_iam_user_access_key
  curator_iam_user_secret_key = var.curator_iam_user_secret_key

  providers = {
    kubectl.this = kubectl.this
  }

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

  region          = var.region
  config_repo_url = var.config_repo_url
  image_tag       = var.config_server_image_tag
  secret_name     = var.bitbucket_key_secrets_manager_name

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
