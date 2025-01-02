output "cluster" {
  description = "EKS Cluster name"
  value       = module.cluster.cluster
}

output "cluster_role_arn" {
  description = "role arn id for cluster"
  value       = module.iam.cluster_role_arn
}

output "node_role_arn" {
  description = "role arn id for cluster nodes"
  value       = module.iam.node_role_arn
}

output "efs_id" {
  description = "EFS volume ID for EKS Cluster"
  value       = module.efs.efs_id
}

output "grafana_role_arn" {
  description = "role arn id for cloudwatch datasource in grafana"
  value       = module.iam.grafana_role_arn
}

output "primary_security_group_id" {
  value = module.cluster.primary_security_group_id
}

output "elb_security_group" {
  value = aws_security_group.elb_sg.id
}

output "internal_alb_security_group" {
  value = aws_security_group.internal_alb_sg.id
}

output "cluster_cert" {
value = module.cluster.cluster_cert
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

