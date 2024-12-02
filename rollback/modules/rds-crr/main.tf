terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      configuration_aliases = [aws.dr]
    }
  }
}

data "aws_vpc" "rds" {
  id = var.vpc_id

  provider = aws.dr
}

resource "aws_rds_cluster" "dr" {
  cluster_identifier              = var.name
  db_cluster_parameter_group_name = var.rds_cluster_parameter_group_name
  vpc_security_group_ids          = [var.security_group]
  db_subnet_group_name            = var.db_subnet_group_id
  engine                          = var.engine
  engine_version                  = var.engine_version
  skip_final_snapshot             = true
  storage_encrypted               = true
  copy_tags_to_snapshot           = true
  backup_retention_period         = var.backup_retention_period
  deletion_protection             = var.deletion_protection
  replication_source_identifier   = var.primary_rds_cluster_arn
  kms_key_id                      = var.kms_key_id
  source_region                   = var.region
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  provider = aws.dr

}

resource "aws_rds_cluster_instance" "dr" {

  identifier              = "${var.name}-1"
  cluster_identifier      = aws_rds_cluster.dr.id
  instance_class          = var.instance_class
  db_subnet_group_name    = var.db_subnet_group_id
  engine                  = var.engine
  db_parameter_group_name = var.db_parameter_group_name
  depends_on              = [aws_rds_cluster.dr]

  provider = aws.dr
}