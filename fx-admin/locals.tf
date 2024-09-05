locals {

  baton_application_namespaces = {
    for ns_key, ns_value in var.baton_application_namespaces : ns_key => merge(
      ns_value,
      ns_key == var.prod_namespace && var.is_prod ? {
        services = {
          for service_key, service_value in ns_value.services : service_key => merge(
            service_value,
            {
              command = service_key == "swiftservice" ? [
                "/bin/sh",
                "-c",
                <<-EOT
cp /home/app/app-cm/sftp-rsa /home/app/sftp-rsa && chmod 400 /home/app/sftp-rsa && ( ssh -oStrictHostKeyChecking=no -i /home/app/sftp-rsa -f ubuntu@${module.sftp_host[0].eip} -L 3000:${var.triana_sftp_host_endpoint}:22 -N &> output.log & ) && echo 'Updated command for swiftservice' && sleep 30m
EOT
              ] : service_value.command
              config_map = service_key == "swiftservice" ? merge(service_value.config_map, {
                "sftp-rsa" = try(module.sftp_host[0].sftp_rsa, "empty")
              }) : service_value.config_map
            }
          )
        }
      } : {}
    )
  }

  nlb_cnames = toset(["rabbitmq"])

  external_elb_cnames = toset([""])

  resources_key_user_arns = [module.lambda_iam.lambda_role_arn, module.kinesis_app.role_arn, var.eks_cluster_role_arn, var.eks_node_role_arn, module.kinesis_firehose.firehose_role_arn]

  jq_ip = data.external.rabbitmq_private_ip.result

  reg_ip = regex("(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})", local.jq_ip.ip)

  env_secrets = var.env_secrets != "" && var.env_secrets != null ? jsondecode(data.aws_secretsmanager_secret_version.env_secrets[0].secret_string) : {}
}
