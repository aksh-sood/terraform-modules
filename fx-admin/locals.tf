locals {

  baton_application_namespaces = {
    for ns_key, ns_value in var.baton_application_namespaces : ns_key => merge(
      ns_value,
      ns_key == var.prod_namespace && var.is_prod ? {
        services = {
          for service_key, service_value in ns_value.services : service_key => merge(
            service_value,
            {
              command = service_key == "swiftservice" ? var.swift_prod_cmd == [] || var.swift_prod_cmd == null ? [
                "/bin/sh",
                "-c",
                <<-EOT
cp /home/app/app-cm/sftp-rsa /home/app/sftp-rsa && chmod 400 /home/app/sftp-rsa && ( ssh -oStrictHostKeyChecking=no -i /home/app/sftp-rsa -f ubuntu@${module.sftp_host[0].eip} -L 3000:${var.triana_sftp_host_endpoint}:22 -N &> output.log & ) && echo 'Tunnel is running' && "java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -XX:+ExitOnOutOfMemoryError -jar /home/app/app.jar"
EOT
              ] : var.swift_prod_cmd : service_value.command
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

  rabbitmq_endpoint = try(
    regex("(?:https?|amqps)://([^/:]+)(?::\\d+)?", module.rabbitmq.console_url)[0],
    trimsuffix(module.rabbitmq.console_url, "/")
  )

  rabbitmq_private_ips = { for r in jsondecode(data.http.dns_query.response_body)["Answer"] :
    r["data"] => r if r["type"] == 1
  }

  env_secrets = var.env_secrets != "" && var.env_secrets != null ? jsondecode(data.aws_secretsmanager_secret_version.env_secrets[0].secret_string) : {}

  cloudwatch_alerts = merge(
    {
      "RDS Connections" = {
        name                = "[RDS]DB Connections reached threshold-400"
        description         = "[RDS]DB Connections reached threshold-400"
        metric_name         = "DatabaseConnections"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "400"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "300"
        datapoints_to_alarm = "1"
        treat_missing_data  = "breaching"
        dimensions = try({
          DBInstanceIdentifier = tolist(module.rds_cluster[0].cluster_instances)[0]
        }, {})
      },
      "RDS CPU Utilization over 60 for Writer" = {
        name                = "[RDS] Writer - Maximum CPUUtilization GreaterThanThreshold 60.0"
        description         = "[RDS] Writer - Maximum CPUUtilization GreaterThanThreshold 60.0"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanThreshold"
        threshold           = "60"
        namespace           = "AWS/RDS"
        statistic           = "Maximum"
        period              = "60"
        datapoints_to_alarm = "5"
        treat_missing_data  = "breaching"
        dimensions = try({
          DBInstanceIdentifier = tolist(module.rds_cluster[0].cluster_instances)[0]
        }, {})
      },
      "RDS CPU Utilization over 70 for Writer" = {
        name                = "[RDS] Writer - Maximum CPUUtilization GreaterThanThreshold 70.0"
        description         = "[RDS] Writer - Maximum CPUUtilization GreaterThanThreshold 70.0"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanThreshold"
        threshold           = "70"
        namespace           = "AWS/RDS"
        statistic           = "Maximum"
        period              = "60"
        datapoints_to_alarm = "5"
        treat_missing_data  = "breaching"
        dimensions = try({
          DBInstanceIdentifier = tolist(module.rds_cluster[0].cluster_instances)[0]
        }, {})
      },
      "OpenSearch Has Low Storage" = {
        name                = "OpenSearch Low Storage Space - Action Required"
        description         = "The OpenSearch instance in the production environment is experiencing low storage space, which may impact cluster performance..."
        metric_name         = "FreeStorageSpace"
        comparison_operator = "LessThanOrEqualToThreshold"
        threshold           = "30000"
        namespace           = "AWS/ES"
        statistic           = "Average"
        period              = "3600"
        datapoints_to_alarm = "1"
        treat_missing_data  = "missing"
        dimensions = {
          DomainName = var.opensearch_domain_name
          ClientId   = data.aws_caller_identity.current.account_id
        }
      },
      "RDS Replication" = {
        name                = "RDS-Replication-binlog-lag"
        description         = "RDS-Replication-binlog-lag"
        metric_name         = "AuroraBinlogReplicaLag"
        comparison_operator = "LessThanThreshold"
        threshold           = "0"
        namespace           = "AWS/RDS"
        statistic           = "Maximum"
        period              = "300"
        datapoints_to_alarm = "1"
        treat_missing_data  = "breaching"
        dimensions = try({
          DBInstanceIdentifier = tolist(module.rds_cluster[0].cluster_instances)[0]
        }, {})
      },
      "RabbitMQ High Queue Depth" = {
        name                = "RabbitMQ-Queue-depth-greater-than-5000"
        description         = "RabbitMQ-Queue-depth-greater-than-5000: This can indicate a backlog or delay in message processing..."
        metric_name         = "MessageCount"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "5000"
        namespace           = "AWS/AmazonMQ"
        statistic           = "Average"
        period              = "300"
        datapoints_to_alarm = "1"
        treat_missing_data  = "breaching"
        dimensions = {
          Broker = module.rabbitmq.rabbitmq_broker
        }
      }
    },
  )

  pagerduty_integration_key = try(var.cloudwatch_alerts_pagerduty_integration_key, "")
}
