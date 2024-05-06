data "aws_vpc" "rds" {
  id = var.vpc_id
}

locals {
  additional_security_group_ids = [
    for item in var.ingress_whitelist : item if can(regex("^sg-[a-fA-F0-9]{8,17}$", item))
  ]

  additional_cidrs = [
    for item in var.ingress_whitelist : item if can(regex("^(?:\\d{1,3}\\.){3}\\d{1,3}(?:/\\d{1,2})$", item))
  ]

  security_group_rules = merge(
    {
      for sg in local.additional_security_group_ids :
      "additional_sg_${sg}" => {
        source_security_group_id = sg
      }
    },
    local.additional_cidrs != [] ? {
      additional_cidr_blocks = {
        cidr_blocks = local.additional_cidrs
      }
    } : {}
  )
}

resource "random_password" "password" {
  length      = 16
  special     = false
  lower       = true
  min_lower   = 1
  numeric     = true
  min_numeric = 1
  upper       = true
  min_upper   = 1
}

# Define RDS Aurora Cluster module
module "rds_cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"
  # https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/8.5.0
  version = "8.5.0"

  # General Configuration
  name                                  = var.name
  engine                                = "aurora-mysql"
  engine_version                        = var.mysql_version
  instance_class                        = var.rds_instance_type
  master_username                       = var.master_username
  manage_master_user_password           = false
  master_password                       = random_password.password.result
  deletion_protection                   = var.enable_deletion_protection
  kms_key_id                            = var.kms_key_id
  auto_minor_version_upgrade            = var.enable_auto_minor_version_upgrade
  preferred_backup_window               = var.preferred_backup_window
  backup_retention_period               = var.backup_retention_period
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null
  publicly_accessible                   = var.publicly_accessible
  storage_encrypted                     = true
  ca_cert_identifier                    = var.ca_cert_identifier
  create_db_subnet_group                = true
  db_subnet_group_name                  = "${var.name}-db-subnet-group"
  subnets                               = var.subnets

  create_cloudwatch_log_group     = true
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  create_db_parameter_group       = true
  db_parameter_group_family       = var.parameter_group_family
  db_parameter_group_description  = "${var.name}-RDS Cluster Parameter Group"
  db_parameter_group_parameters   = var.db_parameter_group_parameters


  # Add a custom DB cluster parameter group
  create_db_cluster_parameter_group     = var.create_db_cluster_parameter_group
  db_cluster_parameter_group_name       = "rds-cluster-parameter-group-in-${var.name}"
  db_cluster_parameter_group_family     = var.parameter_group_family
  db_cluster_parameter_group_parameters = try(var.db_cluster_parameter_group_parameters, [])

  skip_final_snapshot       = true # For prod env should be set to false. In that case final_snapshot_identifier is required. Set to true in test scenarios
  final_snapshot_identifier = "snapshot-made-while-deletion-of-${var.name}-rds-cluster"

  instances = {
    1 = {
      promotion_tier = 0
    }
  }


  # Security Group Configuration
  vpc_id                         = var.vpc_id
  create_security_group          = true
  security_group_name            = "RDS"
  security_group_use_name_prefix = true
  security_group_rules           = local.security_group_rules

  # Tags
  tags = merge(var.cost_tags, {
    Name = "${var.name}-RDS"
  })

  #security-hub special requirements
  copy_tags_to_snapshot = true

}

# Event Notification for RDS
resource "aws_sns_topic" "rds" {
  name = "rds-cluster-events"
}

locals {
  event_subscriptions = [
    {
      name             = "${var.name}-rds-cluster-events-sub"
      source_type      = "db-cluster"
      source_ids       = [module.rds_cluster.cluster_id]
      event_categories = ["failure", "maintenance"]
    },
    {
      name             = "${var.name}-rds-events-sub"
      source_type      = "db-instance"
      source_ids       = module.rds_cluster.cluster_members
      event_categories = ["failure", "maintenance", "configuration change"]
    },
    {
      name             = "${var.name}-rds-db-parameter-group-sub"
      source_type      = "db-parameter-group"
      source_ids       = [module.rds_cluster.db_parameter_group_id]
      event_categories = ["configuration change"]
    }
  ]
}

resource "aws_db_event_subscription" "event_subscriptions" {
  count            = var.enable_rds_event_notifications ? length(local.event_subscriptions) : 0
  name             = local.event_subscriptions[count.index].name
  sns_topic        = aws_sns_topic.rds.arn
  source_type      = local.event_subscriptions[count.index].source_type
  source_ids       = local.event_subscriptions[count.index].source_ids
  event_categories = local.event_subscriptions[count.index].event_categories
}

resource "aws_security_group_rule" "eks_sg" {
  count = var.whitelist_eks ? 1 : 0

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.eks_sg
  security_group_id        = module.rds_cluster.security_group_id
}

resource "aws_security_group_rule" "allow_egress_in_vpc" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.rds]
  from_port         = 0
  security_group_id = module.rds_cluster.security_group_id
}

resource "aws_rds_cluster_instance" "reader_instance" {
  count = var.create_rds_reader ? 1 : 0

  promotion_tier                        = 1
  identifier                            = "${var.name}-2"
  cluster_identifier                    = module.rds_cluster.cluster_id
  instance_class                        = try(var.reader_instance_type, var.rds_instance_type)
  engine                                = "aurora-mysql"
  engine_version                        = module.rds_cluster.cluster_engine_version_actual
  publicly_accessible                   = var.publicly_accessible
  copy_tags_to_snapshot                 = true
  db_parameter_group_name               = module.rds_cluster.db_parameter_group_id
  db_subnet_group_name                  = module.rds_cluster.db_subnet_group_name
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null
  auto_minor_version_upgrade            = var.enable_auto_minor_version_upgrade

  tags = merge(var.cost_tags, {
    Name      = "${var.name}-RDS"
    Terraform = "true"
  })
}
