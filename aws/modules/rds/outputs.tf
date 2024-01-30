output "writer_endpoint" {
  value       = module.rds_cluster.cluster_endpoint
  description = "Writer endpoint of the RDS cluster."
}

output "reader_endpoint" {
  value       = module.rds_cluster.cluster_reader_endpoint
  description = "Reader endpoint of the RDS cluster."
}

output "master_password" {
  value = random_password.password.result
  sensitive = true
}

output "master_username" {
  value = var.master_username
}