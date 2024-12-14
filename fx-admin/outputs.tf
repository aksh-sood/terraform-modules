output "activemq_url" {
  value = [module.activemq[0].url_1,module.activemq[0].url_2]
}

output "activemq_password" {
  value     = module.activemq[0].password
  sensitive = true
}

output "activemq_username" {
  value     = var.activemq_username
  sensitive = true
}


output "rabbitmq_password" {
  value     = module.rabbitmq.password
  sensitive = true
}

output "rabbitmq_username" {
  value = module.rabbitmq.username
}

output "rabbitmq_endpoint" {
  value = module.rabbitmq.endpoint
}

output "rabbitmq_nlb_url" {
  value = module.rabbitmq_nlb.url
}

output "primary_rds_cluster_parameter_group_name" {
  value = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].db_cluster_parameter_group_id : null
}

output "primary_db_subnet_group_id" {
  value = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].db_subnet_group_name : null
}

output "db_parameter_group_name" {
  value = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].db_parameter_group_id : null
}

output "primary_rds_security_group_id" {
  value = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].security_group_id : null
}

output "rds_writer_endpoint" {
  description = "Writer endpoint of the RDS cluster"
  value       = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].writer_endpoint : null
}

output "rds_reader_endpoint" {
  description = "Reader endpoint of the RDS cluster"
  value       = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].reader_endpoint : null
}

output "rds_master_password" {
  value     = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].master_password : null
  sensitive = true
}

output "rds_master_username" {
  value = (!var.is_dr && var.create_rds) ? module.rds_cluster[0].master_username : null
}

output "activemq_credentials" {
  description = "ActiveMQ Credentials for EKS deployments"
  value       = [for ns in module.baton_application_namespace : ns.activemq_credentials if ns.activemq_credentials != null]
  sensitive   = true
}

output "fx_env_kms_key_arn" {
  description = "KMS key ARN for FX ADMIN module resources"
  value       = module.kms_sse.key_arn
}

output "crr_cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = var.setup_dr && (!var.is_dr && var.create_rds) ? module.rds_crr[0].cluster_endpoint : null
}

output "crr_cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = var.setup_dr && (!var.is_dr && var.create_rds) ? module.rds_crr[0].cluster_reader_endpoint : null
}
