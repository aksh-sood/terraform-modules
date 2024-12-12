output "writer_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = aws_rds_cluster.dr.endpoint
}

output "reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = aws_rds_cluster.dr.reader_endpoint
}

output "master_username" {
  description = "RDS cluster username"
  value       = aws_rds_cluster.dr.master_username
}

output "master_password" {
  description = "RDS cluster passowrd"
  value       = aws_rds_cluster.dr.master_password
}