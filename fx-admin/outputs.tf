output "activemq_url" {
  value = module.activemq.url
}

output "activemq_password" {
  value     = module.activemq.password
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

output "rds_writer_endpoint" {
  value       = module.rds_cluster.writer_endpoint
  description = "Writer endpoint of the RDS cluster."
}

output "rds_reader_endpoint" {
  description = "Reader endpoint of the RDS cluster."
  value       = module.rds_cluster.reader_endpoint
}

output "rds_master_password" {
  value     = module.rds_cluster.master_password
  sensitive = true
}

output "rds_master_username" {
  value = module.rds_cluster.master_username
}