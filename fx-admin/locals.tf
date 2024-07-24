locals {

  env_injector = {
    namespace = var.environment
    vendor    = var.vendor
  }

  baton_application_namespaces = length(var.baton_application_namespaces) == 1 ? [merge(var.baton_application_namespaces[0], local.env_injector)] : var.baton_application_namespaces

  nlb_cnames = toset(["rabbitmq"])

  external_elb_cnames = toset([""])

  resources_key_user_arns = [module.lambda_iam.lambda_role_arn, module.kinesis_app.role_arn, var.eks_cluster_role_arn, var.eks_node_role_arn, module.kinesis_firehose.firehose_role_arn]

  jq_ip = data.external.rabbitmq_private_ip.result

  reg_ip = regex("(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})", local.jq_ip.ip)
}