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