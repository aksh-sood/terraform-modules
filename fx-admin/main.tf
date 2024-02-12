module "s3_swift" {
  source = "../commons/aws/s3"

  name = "baton-${var.environment}-swift-messages"
  environment = var.environment
  tags        = var.cost_tags
}

module "s3_baton" {
  source = "../commons/aws/s3"

  name = "baton-${var.environment}"
  environment = var.environment
  tags        = var.cost_tags
}

module "kinesis_firehose" {
  source = "./modules/kinesis-firehose"

  bucket_arn = module.s3_baton.bucket_arn

  environment = var.environment
  region = var.region
  tags   = var.cost_tags
}

module "normalized_trml_kinesis_stream" {
  source = "../commons/aws/stream"

  name        = "${var.environment}-normalized-trml"
  environment = var.environment
  tags        = var.cost_tags
}

module "matched_trades_kinesis_stream" {
  source = "../commons/aws/stream"

  name        = "${var.environment}-matched-trades"
  environment = var.environment
  tags        = var.cost_tags
}

module "kinesis_app" {
  source = "./modules/kinesis-app"

  normalized_trades_arn = module.normalized_trml_kinesis_stream.stream_arn
  matched_trades_arn    = module.matched_trades_kinesis_stream.stream_arn

  environment = var.environment
  region      = var.region
  tags        = var.cost_tags
}

module "lambda_iam" {
  source = "../commons/aws/lambda-iam"

  environment = var.environment
  region      = var.region
}

module "normalized_trml_lambda" {
  source = "../commons/aws/lambda"

  stream_arn      = module.normalized_trml_kinesis_stream.stream_arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "normalized-trades"
  package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  region                    = var.region
  vpc_id                    = var.vpc_id
  environment               = var.environment
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  environment_variables = {
    data_type           = "normalized_trades"
    destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
    activemq_broker_url = "failover:(${module.activemq.activemq_url},${module.activemq.activemq_url})?jms.userName=${module.activemq.activemq_username}&jms.password=${module.activemq.activemq_password}"
  }

  tags = var.cost_tags
}

module "matched_trades_lambda" {
  source = "../commons/aws/lambda"

  stream_arn      = module.matched_trades_kinesis_stream.stream_arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "matched-trades"
  package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  environment               = var.environment
  region                    = var.region
  vpc_id                    = var.vpc_id
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  environment_variables = {
    data_type           = "matched_trades"
    destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
    activemq_broker_url = "failover:(${module.activemq.activemq_url},${module.activemq.activemq_url})?jms.userName=${module.activemq.activemq_username}&jms.password=${module.activemq.activemq_password}"
  }
  tags = var.cost_tags

}

module "s3_writer_lambda" {
  source = "../commons/aws/lambda"

  sqs_arn = module.sqs.arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  stream_arn = null
  name                      = "s3-writer"
  package_key               = "s3-writer-lambda-0.0.1-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  environment               = var.environment
  region                    = var.region
  vpc_id                    = var.vpc_id
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  environment_variables = {
    region         = var.region
    s3_bucket_name = "baton-${var.environment}-bucket"
  }
  tags = var.cost_tags
}

module "sqs" {
  source = "../commons/aws/sqs"

  name        = "normalizer"
  environment = var.environment
  tags        = var.cost_tags
}

module "activemq" {
  source = "../commons/aws/activemq"

  activemq_engine_version      = var.activemq_engine_version
  activemq_host_instance_type  = var.activemq_host_instance_type
  activemq_publicly_accessible = var.activemq_publicly_accessible
  apply_immediately            = var.apply_immediately
  activemq_storage_type        = var.activemq_storage_type
  activemq_username            = var.activemq_username
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  environment                  = var.environment
  subnet_ids                   = var.public_subnet_ids
  vpc_id                       = var.vpc_id
  whitelist_security_groups    = [var.eks_security_group, module.matched_trades_lambda.security_group_id, module.normalized_trml_lambda.security_group_id]

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
  rds_reader_needed                     = var.rds_reader_needed
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

module "baton_application_namespaces" {
  source = "../commons/kubernetes/baton-application-namespace"

  domain_name                  = var.domain_name
  environment                  = var.environment
  baton_application_namespaces = var.baton_application_namespaces

  providers = {
    kubectl.this = kubectl.this
  }
}