module "addons" {
  source = "./modules/addons"

  cluster_name = var.environment
  lbc_version  = var.lbc_version
  efs_version  = var.efs_version
  efs_id       = var.efs_id

}

module "istio" {
  source = "./modules/istio"

  acm_certificate_arn    = var.acm_certificate_arn
  istio_version          = var.istio_version
  siem_storage_s3_bucket = var.siem_storage_s3_bucket

  depends_on = [module.addons]
}

