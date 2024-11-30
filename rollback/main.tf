module "rds_crr" {
  source = "./modules/rds-crr"

  name                             = var.environment
  region                           = var.region
  security_group                   = var.primary_rds_security_group_id
  rds_cluster_parameter_group_name = var.primary_rds_cluster_parameter_group_name
  db_subnet_group_id               = var.primary_db_subnet_group_id
  primary_rds_cluster_arn          = var.dr_rds_cluster_arn
  vpc_id                           = var.primary_central_vpc_id
  dr_eks_security_group            = var.primary_crr_rds_config.eks_security_group
  subnet_ids                       = var.primary_crr_rds_config.subnet_ids
  kms_key_id                       = var.primary_crr_rds_config.kms_key_id
  deletion_protection              = var.primary_crr_rds_config.deletion_protection
  db_parameter_group_parameters    = var.primary_crr_rds_config.db_parameter_group_parameters
  engine_version                   = var.primary_crr_rds_config.engine_version
  backup_retention_period          = var.primary_crr_rds_config.backup_retention_period
  instance_class                   = var.primary_crr_rds_config.instance_type
  parameter_group_family           = var.primary_crr_rds_config.parameter_group_family
  enabled_cloudwatch_logs_exports  = var.primary_crr_rds_config.enabled_cloudwatch_logs_exports
  db_parameter_group_name          = var.db_parameter_group_name
  tags                             = var.cost_tags

  providers = {
    aws.dr = aws.primary
  }

}