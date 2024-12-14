module "rds_crr" {
  source = "../commons/aws/rds-crr"

  name                             = var.environment
  region                           = var.region
  security_group                   = var.primary_rds_security_group_id
  rds_cluster_parameter_group_name = var.primary_rds_cluster_parameter_group_name
  db_subnet_group_id               = var.primary_db_subnet_group_id
  vpc_id                           = var.vpc_id
  dr_eks_security_group            = var.eks_security_group
  subnet_ids                       = var.private_subnet_ids
  kms_key_id                       = var.kms_key_arn
  db_parameter_group_name          = var.db_parameter_group_name

  primary_rds_cluster_arn = var.secondary_rds_cluster_arn

  engine_version                        = var.rds_config.engine_version
  backup_retention_period               = var.rds_config.backup_retention_period
  deletion_protection                   = var.rds_config.enable_deletion_protection
  db_cluster_parameter_group_parameters = var.rds_config.db_cluster_parameter_group_parameters
  instance_class                        = var.rds_config.instance_type
  parameter_group_family                = var.rds_config.parameter_group_family
  enabled_cloudwatch_logs_exports       = var.rds_config.enabled_cloudwatch_logs_exports

  create_sg                          = false
  create_rds_cluster_parameter_group = false
  create_db_subnet_group             = false

  tags = var.cost_tags
}