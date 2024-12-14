terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

data "aws_vpc" "rds" {
  id = var.vpc_id
}

#Security group
resource "aws_security_group" "rds_dr" {
  count = var.create_sg ? 1 : 0

  name        = "${var.name}-RDS-dr"
  description = "RDS security group for RDS cluster in DR region"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "eks_sg" {
  count = var.whitelist_eks && var.create_sg ? 1 : 0

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = var.dr_eks_security_group
  security_group_id        = aws_security_group.rds_dr[0].id
}

resource "aws_security_group_rule" "allow_egress_in_vpc" {
  count = var.whitelist_eks && var.create_sg ? 1 : 0

  type              = "egress"
  protocol          = "-1"
  to_port           = 0
  from_port         = 0
  cidr_blocks       = [data.aws_vpc.rds.cidr_block]
  security_group_id = aws_security_group.rds_dr[0].id
}

#RDS DR creation

resource "aws_db_subnet_group" "dr" {
  count = var.create_db_subnet_group ? 1 : 0

  name_prefix = var.name
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

resource "aws_rds_cluster_parameter_group" "dr" {
  count = var.create_rds_cluster_parameter_group ? 1 : 0

  name_prefix = var.name
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.db_cluster_parameter_group_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, "immediate")
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_rds_cluster" "dr" {
  cluster_identifier              = var.name
  db_cluster_parameter_group_name = var.create_rds_cluster_parameter_group ? aws_rds_cluster_parameter_group.dr[0].name : var.rds_cluster_parameter_group_name
  vpc_security_group_ids          = var.create_sg ? [aws_security_group.rds_dr[0].id] : [var.security_group]
  db_subnet_group_name            = var.create_db_subnet_group ? aws_db_subnet_group.dr[0].id : var.db_subnet_group_id
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
}

resource "aws_rds_cluster_instance" "dr" {

  identifier           = "${var.name}-1"
  cluster_identifier   = aws_rds_cluster.dr.id
  instance_class       = var.instance_class
  db_subnet_group_name = var.create_db_subnet_group ? aws_db_subnet_group.dr[0].id : var.db_subnet_group_id
  engine               = var.engine

  depends_on = [aws_rds_cluster.dr]
}