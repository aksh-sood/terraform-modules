output "writer_endpoint" {
  description = "Writer endpoint of the RDS cluster"
  value       = module.rds_cluster.cluster_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint of the RDS cluster"
  value       = module.rds_cluster.cluster_reader_endpoint
}

output "master_password" {
  value     = module.rds_cluster.cluster_master_password
  sensitive = true
}

output "master_username" {
  value = module.rds_cluster.cluster_master_username
}

output "sns_topic_arn" {
  value = aws_sns_topic.rds.arn
}

output "cluster_arn" {
  description = "ARN of the RDS cluster"
  value       = module.rds_cluster.cluster_arn
}

output "cluster_instances" {
  description = "Name of the RDS cluster writer instance"
  value       = module.rds_cluster.cluster_members
}


output "cluster_id" {
  description = "Name of the RDS cluster"
  value       = module.rds_cluster.cluster_id
}

output "db_subnet_group_name" {
  value = module.rds_cluster.db_subnet_group_name
}

output "db_parameter_group_id" {
  value = module.rds_cluster.db_parameter_group_id
}

output "db_cluster_parameter_group_id" {
  value = module.rds_cluster.db_cluster_parameter_group_id
}

output "security_group_id" {
  value = module.rds_cluster.security_group_id
}

output "global_rds_identifier" {
  value = var.create_global_cluster ?aws_rds_global_cluster.this[0].id:null
}