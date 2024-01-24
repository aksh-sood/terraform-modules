output "writer_endpoint" {
  description = "Writer endpoint of the RDS cluster"
  value       = module.rds_cluster.cluster_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint of the RDS cluster"
  value       = module.rds_cluster.cluster_reader_endpoint
}

output "master_password" {
  value = random_password.password.result
  sensitive = true
}

output "master_username" {
  value = var.master_username
}