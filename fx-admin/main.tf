data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "env_secrets" {
  count     = var.env_secrets != "" && var.env_secrets != null ? 1 : 0
  secret_id = var.env_secrets
}

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

resource "null_resource" "directory_service_data_import_validation" {
  lifecycle {
    precondition {
      condition = var.import_directory_service_db ? (
        var.directory_service_data_s3_bucket_name != "" && var.directory_service_data_s3_bucket_name != null &&
        var.directory_service_data_s3_bucket_path != "" && var.directory_service_data_s3_bucket_path != null
      ) : true
      error_message = "Provide directory_service_data_s3_bucket_name and directory_service_data_s3_bucket_prefix"
    }
  }
}

resource "null_resource" "rds_data_source_validation" {
  lifecycle {
    precondition {
      condition = var.import_directory_service_db ? (
        var.rds_config.snapshot_identifier == null || var.rds_config.snapshot_identifier == ""

      ) : true
      error_message = "import_directory_service_db cannot be true if rds_config.snapshot_identifier is provided"
    }
  }
}

resource "null_resource" "rds_dr_validation" {
  lifecycle {
    precondition {
      condition = var.setup_dr ? (
        var.primary_rds_cluster_arn != "" && var.primary_rds_cluster_arn != null &&
        var.primary_region != "" && var.primary_region != null
      ) : true
      error_message = "Provide correct value for primary_rds_cluster_arn, primary_region"
    }
  }
}

resource "null_resource" "s3_dr_validation" {
  lifecycle {
    precondition {
      condition = var.setup_dr ? (
        var.primary_kms_key_arn != "" && var.primary_kms_key_arn != null
      ) : true
      error_message = "Provide correct value for primary_kms_key_arn"
    }
  }
}

module "sftp_host" {
  source = "../commons/aws/sftp-host"
  count  = var.is_prod ? 1 : 0

  vpc_id                  = var.vpc_id
  region                  = var.region
  subnet_id               = var.public_subnet_ids[0]
  keys_s3_bucket          = var.keys_s3_bucket
  eks_security_group      = var.eks_security_group
  ingress_whitelist       = var.sftp_ingress_whitelist
  ami_id                  = var.sftp_ami_id
  kms_key_id              = var.kms_key_arn
  disable_api_stop        = var.sftp_disable_api_stop
  disable_api_termination = var.sftp_disable_api_termination

  tags = var.cost_tags
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

module "kms_sse" {
  source = "../external/kms"

  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_users                         = local.resources_key_user_arns
  key_service_users                 = local.resources_key_user_arns
  key_service_roles_for_autoscaling = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
  aliases                           = ["resource-${var.environment}-${var.region}"]

  tags = var.cost_tags
}

module "rabbitmq" {
  source = "../commons/aws/rabbitmq"

  name                       = var.environment
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.enable_rabbitmq_cluster ? var.private_subnet_ids : [var.private_subnet_ids[0]]
  whitelist_security_groups  = [var.eks_security_group]
  engine_version             = var.rabbitmq_engine_version
  enable_cluster_mode        = var.rabbitmq_enable_cluster_mode
  instance_type              = var.rabbitmq_instance_type
  eks_security_group         = var.eks_security_group
  rabbitmq_whitelist_ips     = var.rabbitmq_whitelist_ips
  username                   = var.rabbitmq_username
  auto_minor_version_upgrade = var.rabbitmq_auto_minor_version_upgrade
  apply_immediately          = var.rabbitmq_apply_immediately
  deployment_mode            = var.enable_rabbitmq_cluster ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"

  tags = var.cost_tags
}

module "rabbitmq_nlb" {
  source = "./modules/rabbitmq_nlb"

  rabbitmq_sg       = module.rabbitmq.rabbitmq_sg
  rabbitmq_endpoint = module.rabbitmq.endpoint

  name                   = var.environment
  vpc_id                 = var.vpc_id
  subnet_ids             = var.public_subnet_ids
  whitelist_ips          = var.rabbitmq_lb_ingress_whitelist
  public_certificate_arn = var.acm_certificate_arn
  rabbitmq_cluster_mode  = var.enable_rabbitmq_cluster

  tags = var.cost_tags
}

module "nlb_cloudflare" {
  source = "../commons/utilities/cloudflare"
  count  = var.create_dns_records ? 1 : 0

  loadbalancer_url = module.rabbitmq_nlb.url

  cnames      = local.nlb_cnames
  name        = var.environment
  domain_name = var.domain_name

  providers = {
    cloudflare.this = cloudflare.this
  }
}

module "s3_swift" {
  source = "../commons/aws/s3"

  name        = !var.is_dr ? "${var.vendor}-${var.environment}-swift-messages" : "${var.vendor}-${var.environment}-swift-messages-dr"
  kms_key_arn = module.kms_sse.key_arn

  tags = var.cost_tags
}

module "swift_s3_crr" {
  source = "../commons/aws/s3-crr"

  count = var.setup_dr && var.is_dr ? 1 : 0

  name                  = "${var.environment}-swift"
  primary_bucket_name   = "${var.vendor}-${var.environment}-swift-messages"
  primary_kms_key       = var.primary_kms_key_arn
  secondary_bucket_name = module.s3_swift.id
  secondary_kms_key     = module.kms_sse.key_arn

  providers = {
    aws.primary = aws.primary
  }

  depends_on = [null_resource.s3_dr_validation]
}

module "s3" {
  source = "../commons/aws/s3"

  name        = !var.is_dr ? "${var.vendor}-${var.environment}" : "${var.vendor}-${var.environment}-dr"
  kms_key_arn = module.kms_sse.key_arn

  tags = var.cost_tags
}

module "s3_crr" {
  source = "../commons/aws/s3-crr"

  count = var.setup_dr && var.is_dr ? 1 : 0

  name                  = var.environment
  primary_bucket_name   = "${var.vendor}-${var.environment}"
  primary_kms_key       = var.primary_kms_key_arn
  secondary_bucket_name = module.s3.id
  secondary_kms_key     = module.kms_sse.key_arn

  providers = {
    aws.primary = aws.primary
  }

  depends_on = [null_resource.s3_dr_validation]
}

module "kinesis_firehose" {
  source = "./modules/kinesis-firehose"

  bucket_arn  = module.s3.bucket_arn
  kms_key_arn = module.kms_sse.key_arn

  name   = var.environment
  region = var.region

  tags = var.cost_tags
}

module "normalized_trml_kinesis_stream" {
  source = "../commons/aws/stream"

  name        = "${var.environment}-normalized-trml"
  kms_key_arn = module.kms_sse.key_arn

  tags = var.cost_tags
}

module "matched_trades_kinesis_stream" {
  source = "../commons/aws/stream"

  name        = "${var.environment}-matched-trades"
  kms_key_arn = module.kms_sse.key_arn

  tags = var.cost_tags
}

module "kinesis_app" {
  source = "./modules/kinesis-app"

  normalized_trades_arn = module.normalized_trml_kinesis_stream.stream_arn
  matched_trades_arn    = module.matched_trades_kinesis_stream.stream_arn

  name   = var.environment
  region = var.region

  tags = var.cost_tags
}

module "lambda_iam" {
  source = "../commons/aws/lambda-iam"

  s3_bucket_arn = module.s3.bucket_arn
  sqs_queue_arn = module.sqs.arn
  streams_arn   = [module.normalized_trml_kinesis_stream.stream_arn, module.normalized_trml_kinesis_stream.stream_arn]

  name   = var.environment
  region = var.region
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
  count  = (var.create_activemq && !var.is_dr) ? 1 : 0

  name                       = var.environment
  region                     = var.region
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.enable_activemq_cluster ? [var.private_subnet_ids[0], var.private_subnet_ids[1]] : [var.private_subnet_ids[0]]
  engine_version             = var.activemq_engine_version
  instance_type              = var.activemq_instance_type
  publicly_accessible        = var.activemq_publicly_accessible
  apply_immediately          = var.activemq_apply_immediately
  username                   = var.activemq_username
  auto_minor_version_upgrade = var.activemq_auto_minor_version_upgrade
  whitelist_security_groups  = var.eks_security_group
  ingress_whitelist_ips      = var.activemq_ingress_whitelist_ips
  egress_whitelist_ips       = var.activemq_egress_whitelist_ips
  deployment_mode            = var.enable_activemq_cluster ? "ACTIVE_STANDBY_MULTI_AZ" : "SINGLE_INSTANCE"
  data_replication_mode      = var.enable_activemq_cluster && var.setup_dr ? "CRDR" : "NONE"
  broker_connections         = var.activemq_connections
  maintenance_window         = var.activemq_maintenance_window
  tags                       = var.cost_tags
}

module "activemq_crr" {
  source = "./activemq"
  count  = var.setup_dr && var.is_dr && var.create_activemq && var.enable_activemq_cluster ? 1 : 0

  name                                = "${var.environment}-dr"
  region                              = var.region
  vpc_id                              = var.vpc_id
  subnet_ids                          = var.enable_activemq_cluster ? [var.private_subnet_ids[0], var.private_subnet_ids[1]] : [var.private_subnet_ids[0]]
  engine_version                      = var.activemq_engine_version
  instance_type                       = var.activemq_instance_type
  publicly_accessible                 = var.activemq_publicly_accessible
  apply_immediately                   = var.activemq_apply_immediately
  username                            = var.activemq_username
  auto_minor_version_upgrade          = var.activemq_auto_minor_version_upgrade
  whitelist_security_groups           = var.eks_security_group
  broker_connections                  = var.activemq_connections
  ingress_whitelist_ips               = var.activemq_ingress_whitelist_ips
  egress_whitelist_ips                = var.activemq_egress_whitelist_ips
  deployment_mode                     = var.enable_activemq_cluster ? "ACTIVE_STANDBY_MULTI_AZ" : "SINGLE_INSTANCE"
  data_replication_mode               = var.enable_activemq_cluster && var.setup_dr ? "CRDR" : "NONE"
  data_replication_primary_broker_arn = var.primary_activemq_broker_arn
  replica_password                    = var.activemq_replica_user_password


  tags = var.cost_tags

}

module "normalized_trml_lambda" {
  source = "../commons/aws/lambda"

  stream_arn                = module.normalized_trml_kinesis_stream.stream_arn
  lambda_role_arn           = module.lambda_iam.lambda_role_arn
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
    activemq_broker_url = "failover:(${module.activemq[0].url_1},${module.activemq[0].url_2})?jms.userName=${module.activemq[0].username}&jms.password=${module.activemq[0].password}"
  }

  tags = var.cost_tags
}

module "matched_trades_lambda" {
  source = "../commons/aws/lambda"

  stream_arn                = module.matched_trades_kinesis_stream.stream_arn
  lambda_role_arn           = module.lambda_iam.lambda_role_arn
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
    activemq_broker_url = "failover:(${module.activemq[0].url_1},${module.activemq[0].url_2})?jms.userName=${module.activemq[0].username}&jms.password=${module.activemq[0].password}"
  }

  tags = var.cost_tags
}

module "rds_cluster" {
  source = "../commons/aws/rds"
  count  = (!var.is_dr && var.create_rds) ? 1 : 0

  whitelist_eks                         = true
  kms_key_id                            = var.kms_key_arn
  subnets                               = var.private_subnet_ids
  vpc_id                                = var.vpc_id
  name                                  =var.primary_rds_cluster_arn!=null&& var.setup_dr && var.is_dr ? var.environment : "${var.environment}-dr"
  create_global_cluster = var.primary_rds_cluster_arn!=null&& var.setup_dr && var.is_dr
  primary_cluster_arn = var.primary_rds_cluster_arn 
  mysql_version                         = var.rds_config.engine_version
  rds_instance_type                     = var.rds_config.instance_type
  master_username                       = var.rds_config.master_username
  create_rds_reader                     = var.rds_config.create_rds_reader
  ingress_whitelist                     = var.rds_config.ingress_whitelist
  enable_performance_insights           = var.rds_config.enable_performance_insights
  performance_insights_retention_period = var.rds_config.performance_insights_retention_period
  enable_rds_event_notifications        = var.rds_config.enable_event_notifications
  enable_deletion_protection            = var.rds_config.enable_deletion_protection
  enable_auto_minor_version_upgrade     = var.rds_config.enable_auto_minor_version_upgrade
  preferred_backup_window               = var.rds_config.preferred_backup_window
  backup_retention_period               = var.rds_config.backup_retention_period
  publicly_accessible                   = var.rds_config.publicly_accessible
  ca_cert_identifier                    = var.rds_config.ca_cert_identifier
  enabled_cloudwatch_logs_exports       = var.rds_config.enabled_cloudwatch_logs_exports
  reader_instance_type                  = var.rds_config.reader_instance_type
  parameter_group_family                = var.rds_config.parameter_group_family
  db_parameter_group_parameters         = var.rds_config.db_parameter_group_parameters
  db_cluster_parameter_group_parameters = var.rds_config.db_cluster_parameter_group_parameters
  snapshot_identifier                   = var.rds_config.snapshot_identifier
  apply_immediately                     = var.rds_config.apply_immediately
  eks_sg                                = var.eks_security_group
  resources_key_arn                     = module.kms_sse.key_arn

  tags = var.cost_tags

  providers = {
    aws.primary = aws.primary
  }

  depends_on = [null_resource.rds_data_source_validation]
}

# module "rds_cluster_crr" {
#   source = "../commons/aws/rds"
#   count  = (!var.is_dr && var.create_rds) ? 1 : 0

#   whitelist_eks                         = true
#   kms_key_id                            = var.kms_key_arn
#   subnets                               = var.private_subnet_ids
#   vpc_id                                = var.vpc_id
#   name                                  = "${var.environment}-dr"
#   create_global_cluster = var.primary_rds_cluster_arn!=null&& var.setup_dr && var.is_dr
#   mysql_version                         = var.rds_config.engine_version
#   rds_instance_type                     = var.rds_config.instance_type
#   master_username                       = var.rds_config.master_username
#   create_rds_reader                     = var.rds_config.create_rds_reader
#   ingress_whitelist                     = var.rds_config.ingress_whitelist
#   enable_performance_insights           = var.rds_config.enable_performance_insights
#   performance_insights_retention_period = var.rds_config.performance_insights_retention_period
#   enable_rds_event_notifications        = var.rds_config.enable_event_notifications
#   enable_deletion_protection            = var.rds_config.enable_deletion_protection
#   enable_auto_minor_version_upgrade     = var.rds_config.enable_auto_minor_version_upgrade
#   preferred_backup_window               = var.rds_config.preferred_backup_window
#   backup_retention_period               = var.rds_config.backup_retention_period
#   publicly_accessible                   = var.rds_config.publicly_accessible
#   ca_cert_identifier                    = var.rds_config.ca_cert_identifier
#   enabled_cloudwatch_logs_exports       = var.rds_config.enabled_cloudwatch_logs_exports
#   reader_instance_type                  = var.rds_config.reader_instance_type
#   parameter_group_family                = var.rds_config.parameter_group_family
#   db_parameter_group_parameters         = var.rds_config.db_parameter_group_parameters
#   db_cluster_parameter_group_parameters = var.rds_config.db_cluster_parameter_group_parameters
#   snapshot_identifier                   = var.rds_config.snapshot_identifier
#   apply_immediately                     = var.rds_config.apply_immediately
#   eks_sg                                = var.eks_security_group
#   resources_key_arn                     = module.kms_sse.key_arn

#   tags = var.cost_tags

#   providers = {
#     aws.primary = aws.primary
#   }

# }

# module "rds_crr" {
#   source = "../commons/aws/rds-crr"
#   count  = var.setup_dr && var.is_dr && var.create_rds ? 1 : 0

#   name                                  = "${var.environment}-dr"
#   region                                = var.region
#   vpc_id                                = var.vpc_id
#   kms_key_id                            = var.kms_key_arn
#   subnet_ids                            = var.private_subnet_ids
#   dr_eks_security_group                 = var.eks_security_group
#   primary_rds_cluster_arn               = var.primary_rds_cluster_arn
#   engine_version                        = var.rds_config.engine_version
#   deletion_protection                   = var.rds_config.enable_deletion_protection
#   parameter_group_family                = var.rds_config.parameter_group_family
#   enabled_cloudwatch_logs_exports       = var.rds_config.enabled_cloudwatch_logs_exports
#   db_cluster_parameter_group_parameters = var.rds_config.db_cluster_parameter_group_parameters
#   backup_retention_period               = var.rds_config.backup_retention_period
#   instance_class                        = var.rds_config.instance_type
#   tags                                  = merge(var.cost_tags, var.dr_tags)

#   depends_on = [null_resource.rds_dr_validation]

# }

module "secrets" {
  source = "../commons/aws/secrets"

  name        = var.environment
  kms_key_arn = module.kms_sse.key_arn

  secrets = merge({
    database_writer_url   = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].writer_endpoint : module.rds_crr[0].writer_endpoint,
    database_readonly_url = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].reader_endpoint : module.rds_crr[0].reader_endpoint,
    database_username     = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].master_username : module.rds_crr[0].master_username,
    database_password     = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].master_password : module.rds_crr[0].master_password,
    activemq_url_1        = module.activemq[0].url_1,
    activemq_url_2        = module.activemq[0].url_2,
    activemq_username     = module.activemq[0].username,
    activemq_password     = module.activemq[0].password,
    swift_bucket_name     = module.s3_swift.id,
    rabbitmq_url          = replace(module.rabbitmq.console_url, "https://", ""),
    rabbitmq_username     = module.rabbitmq.username,
    rabbitmq_password     = module.rabbitmq.password
    aws_account           = data.aws_caller_identity.current.account_id
    aws_region            = var.region,
    sftp_host_triana      = var.sftp_triana_host != null ? var.sftp_triana_host : var.sftp_host
    sftp_user_triana      = var.sftp_triana_username != null ? var.sftp_triana_username : var.sftp_username
    sftp_password_triana  = var.sftp_triana_password != null ? var.sftp_triana_password : var.sftp_password
    sftp_host_baton       = var.sftp_host
    sftp_user_baton       = var.sftp_username
    sftp_password_baton   = var.sftp_password
    domain_name           = var.domain_name
  }, local.env_secrets, var.additional_secrets)
}

resource "kubernetes_namespace_v1" "utility" {
  metadata {
    name = "utility"
  }
}

module "directory_service_data_import" {
  source = "./modules/data-import-job"
  count  = var.import_directory_service_db ? 1 : 0

  namespace      = kubernetes_namespace_v1.utility.metadata[0].name
  database_name  = "${replace(var.environment, "-", "_")}_directory_service"
  rds_writer_url = module.rds_cluster[0].writer_endpoint
  rds_username   = module.rds_cluster[0].master_username
  rds_password   = module.rds_cluster[0].master_password
  bucket_region  = var.directory_service_data_s3_bucket_region
  bucket_name    = var.directory_service_data_s3_bucket_name
  bucket_path    = var.directory_service_data_s3_bucket_path

  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.rds_cluster, null_resource.directory_service_data_import_validation]
}

module "rabbitmq_config" {
  source = "./modules/rabbitmq-config"

  namespace = kubernetes_namespace_v1.utility.metadata[0].name

  rabbitmq_url      = module.rabbitmq.console_url
  rabbitmq_username = module.rabbitmq.username
  rabbitmq_password = module.rabbitmq.password

  vhost    = var.rabbitmq_virtual_host
  exchange = var.rabbitmq_exchange
}

module "baton_application_namespace" {
  source   = "../commons/kubernetes/baton-namespace"
  for_each = { for k, v in local.baton_application_namespaces : k => v }

  domain_name              = var.domain_name
  namespace                = each.key
  customer                 = each.value.customer
  env_config_map           = each.value.env_config_map
  env_config_map_file_path = each.value.env_config_map_file_path
  docker_registry          = each.value.docker_registry
  istio_injection          = each.value.istio_injection
  services                 = each.value.services
  enable_activemq          = each.value.enable_activemq
  providers = {
    kubectl.this = kubectl.this
  }

  depends_on = [module.secrets, module.rabbitmq_config, module.directory_service_data_import]
}

module "opensearch_monitors" {
  source = "./modules/opensearch-alerting"

  slack_webhook_url               = var.opensearch_alert_slack_webhook_url
  gchat_webhook_url               = var.opensearch_alert_gchat_webhook_url
  gchat_high_priority_webhook_url = var.opensearch_alert_gchat_high_priority_webhook_url
  ses_email_recipients            = var.opensearch_alert_ses_email_recipients
  ses_email_config                = var.opensearch_alert_ses_email_config
  pagerduty_integration_key       = var.opensearch_alert_pagerduty_integration_key
  opensearch_endpoint             = var.opensearch_endpoint
  opensearch_username             = var.opensearch_username
  opensearch_password             = var.opensearch_password
  region                          = var.region

}

module "cloudwatch_alerts_gchat_lambda" {
  source = "../commons/aws/gchat-lambda"
  count  = (var.cloudwatch_alerts_high_priority_gchat_webhook_url != null || var.cloudwatch_alerts_slack_webhook_url != null) ? 1 : 0

  gchat_webhook_url         = var.cloudwatch_alerts_high_priority_gchat_webhook_url
  slack_webhook_url         = var.cloudwatch_alerts_slack_webhook_url
  name                      = "${var.environment}-cloudwatch-alerts"
  package_key               = "cloudwatch-to-gchat-lambda.zip"
  lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
  environment               = var.environment
  region                    = var.region
  tags                      = var.cost_tags

}

module "cloudwatch_alerts" {
  source                    = "../commons/aws/cloudwatch-alerts"
  pagerduty_integration_key = var.cloudwatch_alerts_pagerduty_integration_key
  kms_key_arn               = module.kms_sse.key_arn
  email_ids                 = var.email_ids_for_cloudwatch_alarms
  cloudwatch_alerts         = merge(local.cloudwatch_alerts, var.custom_cloudwatch_alerts)
  gchat_lambda              = var.cloudwatch_alerts_high_priority_gchat_webhook_url != null ? module.cloudwatch_alerts_gchat_lambda[0].lambda_name : ""
  gchat_lambda_arn          = var.cloudwatch_alerts_high_priority_gchat_webhook_url != null ? module.cloudwatch_alerts_gchat_lambda[0].lambda_arn : ""
  environment               = var.environment
  region                    = var.region
}

module "transit_gateway" {
  source = "../commons/aws/transit-gateway"
  count  = (var.create_tgw && !var.is_dr) ? 1 : 0

  central_vpc_id            = var.vpc_id
  central_vpc_subnet_ids    = var.private_subnet_ids
  shared_accounts           = var.tgw_shared_accounts
  cost_tags                 = var.cost_tags
  region_routes             = var.tgw_region_routes
  dr_central_vpc_id         = var.dr_central_vpc_id
  dr_central_vpc_subnet_ids = var.dr_central_vpc_subnet_ids

  providers = {
    aws.us-east-1      = aws.us-east-1
    aws.us-west-2      = aws.us-west-2
    aws.ap-southeast-1 = aws.ap-southeast-1
    aws.eu-west-1      = aws.eu-west-1
  }
}
