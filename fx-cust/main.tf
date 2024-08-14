data "aws_caller_identity" "current" {}

resource "null_resource" "domain_validation" {
  lifecycle {
    precondition {
      condition     = var.domain_name != "" && var.domain_name != null
      error_message = "Provide domain_name"
    }
  }
}

resource "null_resource" "loadbalacer_url_validation" {
  lifecycle {
    precondition {
      condition = var.create_dns_records ? (
        var.external_loadbalancer_url != "" && var.external_loadbalancer_url != null
      ) : true
      error_message = "Provide  external loadbalancer url or disable create_dns_records"
    }
  }
}

module "external_alb_cloudflare" {
  source = "../commons/utilities/cloudflare"
  count  = var.create_dns_records ? 1 : 0

  loadbalancer_url = var.external_loadbalancer_url

  cnames      = local.external_elb_cnames
  name        = var.environment
  domain_name = var.domain_name

  providers = {
    cloudflare.this = cloudflare.this
  }
}


module "s3" {
  source = "../commons/aws/s3"

  kms_key_arn = module.kms_sse.arn

  name = "${var.vendor}-${var.environment}"
  tags = var.cost_tags
}

module "transfer_messages_kinesis_stream" {
  source = "../commons/aws/stream"

  kms_key_arn = module.kms_sse.arn

  name = "${var.environment}-transfer-messages"
  tags = var.cost_tags
}

module "sqs" {
  source = "../commons/aws/sqs"

  name = "${var.environment}-transfer-service"
  tags = var.cost_tags
}

module "activemq" {
  source = "../commons/aws/activemq"

  name                       = "${var.environment}-activemq"
  region                     = var.region
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.private_subnet_ids
  auto_minor_version_upgrade = var.activemq_auto_minor_version_upgrade
  engine_version             = var.activemq_engine_version
  instance_type              = var.activemq_instance_type
  publicly_accessible        = var.activemq_publicly_accessible
  apply_immediately          = var.activemq_apply_immediately
  storage_type               = var.activemq_storage_type
  username                   = var.activemq_username
  ingress_whitelist_ips      = var.activemq_ingress_whitelist_ips
  egress_whitelist_ips       = var.activemq_egress_whitelist_ips
  whitelist_security_groups  = var.eks_security_group

  tags = var.cost_tags
}

module "lambda_iam" {
  source = "../commons/aws/lambda-iam"

  name   = var.environment
  region = var.region

  sqs_queue_arn = module.sqs.arn
  s3_bucket_arn = module.s3.bucket_arn
  streams_arn   = [module.transfer_messages_kinesis_stream.stream_arn]
}

module "s3_writer_lambda" {
  source = "../commons/aws/lambda"

  sqs_arn         = module.sqs.arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "s3-writer-${var.environment}"
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

module "transfer_messages_lambda" {
  source = "../commons/aws/lambda"

  stream_arn      = module.transfer_messages_kinesis_stream.stream_arn
  lambda_role_arn = module.lambda_iam.lambda_role_arn

  name                      = "transfer-messages-${var.environment}"
  package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
  handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
  vpc_id                    = var.vpc_id
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  subnet_ids                = var.private_subnet_ids
  security_group            = var.eks_security_group

  environment_variables = {
    data_type           = "transfer_notice"
    destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
    activemq_broker_url = "failover:(${module.activemq.url},${module.activemq.url})?jms.userName=${module.activemq.username}&jms.password=${module.activemq.password}"
  }

  tags = var.cost_tags

}

module "rds_cluster" {
  source = "../commons/aws/rds"

  sns_kms_key_arn = module.kms_sse.arn

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

  cost_tags = var.cost_tags
}

module "kms_sse" {
  source = "../../../external/kms"

  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_users                         = local.resources_key_user_arns
  key_service_users                 = local.resources_key_user_arns
  key_service_roles_for_autoscaling = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
  aliases                           = ["resource-${var.environment}"]

  tags = var.cost_tags
}

module "baton_application_namespace" {
  source   = "../commons/kubernetes/baton-namespace"
  for_each = { for ns in local.baton_application_namespaces : ns.namespace => ns }

  domain_name     = var.domain_name
  namespace       = each.value.namespace
  customer        = each.value.customer
  docker_registry = each.value.docker_registry
  istio_injection = each.value.istio_injection
  services        = each.value.services
  enable_activemq = each.value.enable_activemq

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.secrets]
}

module "redis" {
  source = "./modules/redis"

  region                    = var.region
  vpc_id                    = var.vpc_id
  environment               = var.environment
  subnet_ids                = var.private_subnet_ids
  redis_node_type           = var.redis_node_type
  engine_version            = var.redis_engine_version
  parameter_group_name      = var.redis_parameter_group_name
  whitelist_security_groups = [var.eks_security_group]
  tags                      = var.cost_tags
}

module "cognito" {
  source = "./modules/cognito"

  name            = var.environment
  domain_name     = var.domain_name
  callback_prefix = var.callback_prefix
  logout_prefix   = var.logout_prefix

  providers = {
    validation.this = validation.this
  }
}

data "aws_secretsmanager_secret_version" "user_secrets" {
  count     = length(var.user_secrets) > 0 ? 1 : 0
  secret_id = var.user_secrets
}

module "secrets" {
  source = "../commons/aws/secrets"

  name        = var.environment
  kms_key_arn = var.kms_key_arn
  secrets = merge({
    database_writer_url   = module.rds_cluster.writer_endpoint,
    database_readonly_url = module.rds_cluster.reader_endpoint,
    database_username     = module.rds_cluster.master_username,
    database_password     = module.rds_cluster.master_password,
    activemq_url_1        = module.activemq.url,
    activemq_url_2        = module.activemq.url,
    activemq_username     = module.activemq.username,
    activemq_password     = module.activemq.password,
    # redis_host            = module.redis.cache_nodes
    # aws.cognito.user.pool.id = module.cognito.id
    # aws.cognito.app.client.id = 
    # aws.cognito.app.secret = 
    aws_account = data.aws_caller_identity.current.account_id
    aws_region  = var.region
    domain_name = var.domain_name
  }, local.user_secrets, var.additional_secrets)
}
