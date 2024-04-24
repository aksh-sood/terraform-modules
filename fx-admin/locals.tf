locals {

  env_injector = {
    namespace = var.environment
    vendor    = var.vendor
  }

  baton_application_namespaces = length(var.baton_application_namespaces) == 1 ? [merge(var.baton_application_namespaces[0], local.env_injector)] : var.baton_application_namespaces

}