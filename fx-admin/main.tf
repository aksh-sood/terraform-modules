data "aws_caller_identity" "current" {}

# module "kms_sse" {
#   source = "../external/kms"

#   key_administrators = [
#     data.aws_caller_identity.current.arn
#   ]

#   key_users                         = local.resources_key_user_arns
#   key_service_users                 = local.resources_key_user_arns
#   key_service_roles_for_autoscaling = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
#   aliases                           = ["resource-${var.environment}-${var.region}"]

#   tags = var.cost_tags
# }




module "kinesis_firehose" {
  source = "./modules/kinesis-firehose"

  bucket_arn  = "arn:aws:s3:::baton-fx-baton-prod2"
  kms_key_arn = null
  
  name        = var.environment
  region      = var.region

  tags = var.cost_tags
}

module "kinesis_app" {
  source = "./modules/kinesis-app"

  normalized_trades_arn = "arn:aws:kinesis:us-west-2:010601972186:stream/fx-baton-prod-normalized-trml"
  matched_trades_arn    = "arn:aws:kinesis:us-west-2:010601972186:stream/fx-baton-prod-matched-trades"

  name   = var.environment
  region = var.region

  tags = var.cost_tags
}

# module "lambda_iam" {
#   source = "../commons/aws/lambda-iam"

#   s3_bucket_arn = module.s3.bucket_arn
#   sqs_queue_arn = module.sqs.arn
#   streams_arn   = [module.normalized_trml_kinesis_stream.stream_arn, module.normalized_trml_kinesis_stream.stream_arn]

#   name   = var.environment
#   region = var.region
# }

module "sqs" {
  source = "../commons/aws/sqs"

  name = "${var.environment}-normalizer"

  tags = var.cost_tags
}

# module "s3_writer_lambda" {
#   source = "../commons/aws/lambda"

#   sqs_arn         = module.sqs.arn
#   lambda_role_arn = "arn:aws:iam::010601972186:role/LambdaExecutionRole"

#   name                      = "${var.environment}-s3-writer"
#   package_key               = "s3-writer-lambda-0.0.1-SNAPSHOT.jar"
#   handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
#   vpc_id                    = var.vpc_id
#   security_group            = var.eks_security_group
#   lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
#   subnet_ids                = var.private_subnet_ids

#   environment_variables = {
#     region         = var.region
#     s3_bucket_name = "${var.vendor}-${var.environment}"
#   }

#   tags = var.cost_tags
# }

module "activemq" {
  source = "../commons/aws/activemq"

  name                       = var.environment
  region                     = var.region
  vpc_id                     = var.vpc_id
  subnet_ids                 = [var.public_subnet_ids[0]]
  engine_version             = var.activemq_engine_version
  instance_type              = var.activemq_instance_type
  publicly_accessible        = var.activemq_publicly_accessible
  apply_immediately          = var.activemq_apply_immediately
  username                   = var.activemq_username
  auto_minor_version_upgrade = var.activemq_auto_minor_version_upgrade
  whitelist_security_groups  = var.eks_security_group
  ingress_whitelist_ips      = var.activemq_ingress_whitelist_ips
  egress_whitelist_ips       = var.activemq_egress_whitelist_ips
  deployment_mode            = "SINGLE_INSTANCE"

  # deployment_mode            = var.is_prod ? "ACTIVE_STANDBY_MULTI_AZ" : "SINGLE_INSTANCE"
  tags                       = var.cost_tags
}

# module "normalized_trml_lambda" {
#   source = "../commons/aws/lambda"

#   stream_arn                = "arn:aws:kinesis:us-west-2:010601972186:stream/fx-baton-prod-normalized-trml"
#   lambda_role_arn           = "arn:aws:iam::010601972186:role/LambdaExecutionRole"
#   name                      = "${var.environment}-normalized-trades"
#   package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
#   handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
#   vpc_id                    = var.vpc_id
#   security_group            = var.eks_security_group
#   lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
#   subnet_ids                = var.private_subnet_ids

#   environment_variables = {
#     data_type           = "normalized_trades"
#     destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
#     activemq_broker_url = "failover:(${module.activemq.url},${module.activemq.url})?jms.userName=${module.activemq.username}&jms.password=${module.activemq.password}"
#   }

#   tags = var.cost_tags
# }

# module "matched_trades_lambda" {
#   source = "../commons/aws/lambda"

#   stream_arn                = "arn:aws:kinesis:us-west-2:010601972186:stream/fx-baton-prod-matched-trades"
#   lambda_role_arn           = "arn:aws:iam::010601972186:role/LambdaExecutionRole" 
#   name                      = "${var.environment}-matched-trades"
#   package_key               = "central-streams-to-node-queues-1.0-SNAPSHOT.jar"
#   handler                   = "com.batonsystems.StreamsToQueueLambda::handleRequest"
#   vpc_id                    = var.vpc_id
#   security_group            = var.eks_security_group
#   lambda_packages_s3_bucket = var.lambda_packages_s3_bucket
#   subnet_ids                = var.private_subnet_ids

#   environment_variables = {
#     data_type           = "matched_trades"
#     destination_queue   = replace("${var.environment}-<node>-<data_type>", "${var.vendor}", "<customer>")
#     activemq_broker_url = "failover:(${module.activemq.url},${module.activemq.url})?jms.userName=${module.activemq.username}&jms.password=${module.activemq.password}"
#   }

#   tags = var.cost_tags
# }
