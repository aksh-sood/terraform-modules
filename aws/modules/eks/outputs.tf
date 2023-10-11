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