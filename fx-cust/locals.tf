locals {
 
  env_injector = {
    namespace = var.environment
    vendor    = var.vendor
  }

  baton_application_namespaces = length(var.baton_application_namespaces) == 1 ? [merge(var.baton_application_namespaces[0], local.env_injector)] : var.baton_application_namespaces

  external_elb_cnames = toset([""])

  resources_key_user_arns = [module.lambda_iam.lambda_role_arn, var.eks_cluster_role_arn, var.eks_node_role_arn]

}