output "rds_writer_endpoint" {
  value       = module.rds_cluster.writer_endpoint
  description = "Writer endpoint of the RDS cluster."
}

output "rds_reader_endpoint" {
  value       = module.rds_cluster.reader_endpoint
  description = "Reader endpoint of the RDS cluster."
}

output "rds_master_password" {
  value     = module.rds_cluster.master_password
  sensitive = true
}

output "rds_master_username" {
  value = module.rds_cluster.master_username
}

output "redis_cache_nodes" {
  value = module.redis.cache_nodes
}