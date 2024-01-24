data "aws_caller_identity" "current" {}
//TODO: KMS key should be used by eks nodes
//TODO: KMS key alias with environment name
//TODO: Secuirty Hub is optional 
//TODO: Make logging optional

module "security_hub" {
  source = "./modules/security-hub"

  region                         = var.region
  security_hub_standards         = var.security_hub_standards
  disabled_security_hub_controls = local.disabled_security_hub_controls
}

module "vpc" {
  source = "./modules/vpc"

  create_eks             = var.create_eks
  vpc_cidr               = var.vpc_cidr
  enable_nat_gateway     = var.enable_nat_gateway
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  region                 = var.region
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  cost_tags              = var.cost_tags
  az_count               = local.az_count
  vpc_tags               = merge(var.vpc_tags, { Name = var.environment })
  public_subnet_tags     = merge(var.public_subnet_tags, local.eks_public_subnet_tags)
  private_subnet_tags    = merge(var.private_subnet_tags, local.eks_private_subnet_tags)
}

module "domain_certificate" {
  source = "./modules/domain-certificate"

  acm_certificate_bucket = var.acm_certificate_bucket
  certificate            = var.acm_certificate
  cert_chain             = var.acm_certificate_chain
  private_key            = var.acm_private_key

  acm_tags = var.cost_tags
}

resource "aws_ebs_encryption_by_default" "default_encrypt" {
  enabled = true
}

module "kms" {
  source = "./modules/kms"

  key_user_arns = local.key_user_arns

  environment = var.environment
  kms_tags = var.cost_tags

  depends_on = [aws_ebs_encryption_by_default.default_encrypt]
}

module "eks" {
  source = "./modules/eks"
  count  = var.create_eks ? 1 : 0

  vpc_id              = module.vpc.id
  azs                 = module.vpc.azs
  private_subnet_ids  = module.vpc.private_subnets
  public_subnet_ids   = module.vpc.public_subnets
  kms_key_arn         = module.kms.key_arn
  acm_certificate_arn = module.domain_certificate.certificate_arn

  region                 = var.region
  cluster_name           = var.environment
  cluster_version        = var.cluster_version
  eks_node_groups        = var.eks_node_groups
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  private_subnet_cidrs   = var.private_subnet_cidrs
  eks_tags               = var.cost_tags
  private_subnets_cidr   = var.private_subnet_cidrs
  additional_eks_addons  = var.additional_eks_addons

  depends_on = [module.vpc]
}

module "opensearch" {
  source = "./modules/opensearch"
  count  = var.create_eks ? 1 : 0

  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.public_subnets
  kms_key_arn = module.kms.key_arn
  eks_sg      = var.create_eks ? module.eks[0].primary_security_group_id : null

  domain_name     = var.environment
  engine_version  = var.opensearch_engine_version
  instance_type   = var.opensearch_instance_type
  instance_count  = var.opensearch_instance_count
  ebs_volume_size = var.opensearch_ebs_volume_size
  cost_tags       = var.cost_tags
}

module "rds_cluster" {
  source     = "./modules/rds"
  count      = var.create_rds ? 1 : 0

  kms_key_id                            = module.kms.key_arn
  subnets                               = module.vpc.private_subnets
  vpc_id                                = module.vpc.id
  eks_sg                                = var.create_eks ? module.eks[0].primary_security_group_id : null
  
  name                                  = var.environment
  mysql_version                         = var.rds_mysql_version
  rds_instance_type                     = var.rds_instance_type
  master_username                       = var.rds_master_username
  rds_reader_needed                     = var.rds_reader_needed
  whitelist_eks                         = var.create_eks
  ingress_whitelist                     = var.rds_ingress_whitelist
  enable_performance_insights           = var.rds_enable_performance_insights
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enable_rds_event_notifications        = var.rds_enable_event_notifications
  enable_deletion_protection            = var.rds_enable_deletion_protection
  enable_auto_minor_version_upgrade     = var.rds_enable_auto_minor_version_upgrade
  preferred_backup_window               = var.rds_preferred_backup_window
  backup_retention_period               = var.rds_backup_retention_period
  publicly_accessible                   = var.rds_publicly_accessible
  ca_cert_identifier                    = var.rds_ca_cert_identifier
  enabled_cloudwatch_logs_exports       = var.rds_enabled_cloudwatch_logs_exports
  reader_instance_type                  = var.rds_reader_instance_type
  parameter_group_family                = var.rds_parameter_group_family
  db_cluster_parameter_group_parameters = var.rds_db_cluster_parameter_group_parameters
  db_parameter_group_parameters         = var.rds_db_parameter_group_parameters
  cost_tags                             = var.cost_tags

  depends_on = [module.vpc, module.kms]
}

module "activemq" {
  source                       = "./modules/activemq"
  activemq_engine_version      = var.activemq_engine_version
  activemq_host_instance_type  = var.activemq_host_instance_type
  activemq_publicly_accessible = var.activemq_publicly_accessible
  apply_immediately            = var.apply_immediately
  activemq_storage_type        = var.activemq_storage_type
  activemq_username            = var.activemq_username
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  environment                  = var.environment
  subnet_ids                   = module.vpc.public_subnets
  vpc_id                       = module.vpc.id
  security_group               = module.eks[0].primary_security_group_id
  tags                         = var.cost_tags


}
