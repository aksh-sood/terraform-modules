locals {
  cnames = toset(["rabbitmq"])
}

resource "null_resource" "domain_validation" {
  lifecycle {
    precondition {
      condition = var.domain_name != "" && var.domain_name != null
      error_message = "Provide domain_name"
    }
  }

}

resource "null_resource" "vpn_validation" {
  lifecycle {
    precondition {
      condition = var.create_dns_records ? (
        var.loadbalancer_url != "" && var.loadbalancer_url != null
      ) : true
      error_message = "Provide loadbalancer_urlor disable create_dns_records"
    }
  }

}

module "cloudflare" {
  source = "../commons/utilities/cloudflare"
  count  = var.create_dns_records ? 1 : 0

  loadbalancer_url = var.loadbalancer_url

  cnames           = setunion(local.cnames,var.cnames)
  name             = var.environment
  domain_name      = var.domain_name

  providers = {
    cloudflare.this = cloudflare.this
  }

}

module "rabbitmq" {
  source = "../commons/aws/rabbitmq"

  name                       = var.environment
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.private_subnet_ids
  whitelist_security_groups  = [var.eks_security_group]
  engine_version             = var.rabbitmq_engine_version
  enable_cluster_mode        = var.rabbitmq_enable_cluster_mode
  instance_type              = var.rabbitmq_instance_type
  username                   = var.rabbitmq_username
  auto_minor_version_upgrade = var.rabbitmq_auto_minor_version_upgrade
  publicly_accessible        = var.rabbitmq_publicly_accessible
  apply_immediately          = var.rabbitmq_apply_immediately

  tags = var.cost_tags
}

module "s3_swift" {
  source = "../commons/aws/s3"

  name        = "${var.vendor}-${var.environment}-swift-messages"
  tags        = var.cost_tags
}

module "s3" {
  source = "../commons/aws/s3"

  name        = "${var.vendor}-${var.environment}"
  tags        = var.cost_tags
}

module "kinesis_firehose" {
  source = "./modules/kinesis-firehose"

  bucket_arn = module.s3.bucket_arn

  name        = var.environment
  region      = var.region
  tags        = var.cost_tags
}

module "normalized_trml_kinesis_stream" {
  source = "../commons/aws/stream"

  name        = "${var.environment}-normalized-trml"
  tags        = var.cost_tags
}

module "matched_trades_kinesis_stream" {
  source = "../commons/aws/stream"

  name        = "${var.environment}-matched-trades"
  tags        = var.cost_tags
}

module "kinesis_app" {
  source = "./modules/kinesis-app"

  normalized_trades_arn = module.normalized_trml_kinesis_stream.stream_arn
  matched_trades_arn    = module.matched_trades_kinesis_stream.stream_arn

  name        = var.environment
  region      = var.region
  tags        = var.cost_tags
}

module "lambda_iam" {
  source = "../commons/aws/lambda-iam"

  name        = var.environment
  region      = var.region
}

module "sqs" {
  source = "../commons/aws/sqs"

  name = "${var.environment}-normalizer"
  tags = var.cost_tags
}

module "s3_writer_lambda" {
  source = "../commons/aws/lambda"

  sqs_arn         = module.sqs.arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "${var.environment}-s3-writer"
  package_key               = "s3-writer-lambda-0.0.1-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  vpc_id                    = var.vpc_id
  security_group            = var.eks_security_group
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  environment_variables = {
    region         = var.region
    s3_bucket_name = "${var.vendor}-${var.environment}"
  }
  tags = var.cost_tags
}

module "activemq" {
  source = "../commons/aws/activemq"

  name                       = var.environment
  region                     = var.region
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.public_subnet_ids
  engine_version             = var.activemq_engine_version
  instance_type              = var.activemq_instance_type
  publicly_accessible        = var.activemq_publicly_accessible
  apply_immediately          = var.activemq_apply_immediately
  storage_type               = var.activemq_storage_type
  username                   = var.activemq_username
  auto_minor_version_upgrade = var.activemq_auto_minor_version_upgrade
  whitelist_security_groups  = [var.eks_security_group]

  tags = var.cost_tags
}

module "normalized_trml_lambda" {
  source = "../commons/aws/lambda"

  stream_arn      = module.normalized_trml_kinesis_stream.stream_arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "${var.environment}-normalized-trades"
  package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  vpc_id                    = var.vpc_id
  security_group            = var.eks_security_group
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  environment_variables = {
    data_type           = "normalized_trades"
    destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
    activemq_broker_url = "failover:(${module.activemq.url},${module.activemq.url})?jms.userName=${module.activemq.username}&jms.password=${module.activemq.password}"
  }

  tags = var.cost_tags
}

module "matched_trades_lambda" {
  source = "../commons/aws/lambda"

  stream_arn      = module.matched_trades_kinesis_stream.stream_arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "${var.environment}-matched-trades"
  package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  vpc_id                    = var.vpc_id
  security_group            = var.eks_security_group
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  environment_variables = {
    data_type           = "matched_trades"
    destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
    activemq_broker_url = "failover:(${module.activemq.url},${module.activemq.url})?jms.userName=${module.activemq.username}&jms.password=${module.activemq.password}"
  }
  tags = var.cost_tags

}

module "rds_cluster" {
  source = "../commons/aws/rds"

  whitelist_eks                         = true
  kms_key_id                            = var.kms_key_arn
  subnets                               = var.private_subnet_ids
  vpc_id                                = var.vpc_id
  name                                  = var.environment
  mysql_version                         = var.rds_mysql_version
  rds_instance_type                     = var.rds_instance_type
  master_username                       = var.rds_master_username
  create_rds_reader                     = var.create_rds_reader
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
  eks_sg                                = var.eks_security_group
  cost_tags                             = var.cost_tags
}


module "baton_application_namespace" {
  source = "../commons/kubernetes/baton-namespace"

  for_each = { for ns in var.baton_application_namespaces : ns.namespace => ns }

  domain_name     = var.domain_name
  namespace       = each.value.namespace
  customer        = each.value.customer
  docker_registry = each.value.docker_registry
  istio_injection = each.value.istio_injection
  services        = each.value.services
  common_env      = each.value.common_env

  providers = {
    kubectl.this = kubectl.this
  }
}