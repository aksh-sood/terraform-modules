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

#Security group
resource "aws_security_group" "rds_dr" {
  name        = "${var.name}-RDS-dr"
  description = "RDS security group for RDS cluster in DR region"
  vpc_id      = var.vpc_id
  tags        = var.tags

  provider = aws.dr
}

resource "aws_security_group_rule" "eks_sg" {
  count = var.whitelist_eks ? 1 : 0

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = var.dr_eks_security_group
  security_group_id        = aws_security_group.rds_dr.id

  provider = aws.dr

}

resource "aws_security_group_rule" "allow_egress_in_vpc" {
  type              = "egress"
  protocol          = "-1"
  to_port           = 0
  from_port         = 0
  cidr_blocks       = [data.aws_vpc.rds.cidr_block]
  security_group_id = aws_security_group.rds_dr.id

  provider = aws.dr
}

#RDS DR creation

resource "aws_db_subnet_group" "dr" {
  name_prefix = var.name
  subnet_ids  = var.subnet_ids
  tags        = var.tags

  provider = aws.dr
}

resource "aws_rds_cluster_parameter_group" "dr" {
  name_prefix = var.name
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, "immediate")
    }
  }

  tags = var.tags

  provider = aws.dr
}

resource "aws_rds_cluster" "dr" {
  cluster_identifier              = var.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.dr.name
  vpc_security_group_ids          = [aws_security_group.rds_dr.id]
  db_subnet_group_name            = aws_db_subnet_group.dr.id
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
  depends_on                      = [aws_rds_cluster_parameter_group.dr]

  provider = aws.dr

}

resource "aws_rds_cluster_instance" "dr" {

  identifier           = var.name
  cluster_identifier   = aws_rds_cluster.dr.id
  instance_class       = var.instance_class
  db_subnet_group_name = aws_db_subnet_group.dr.id
  engine               = var.engine
  depends_on           = [aws_rds_cluster.dr]

  provider = aws.dr
}