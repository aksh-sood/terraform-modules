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

output "cluster_endpoint" {
  description = "API endpoint for the cluster"
  value       = module.cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "AWS Clutser certificate"
  value       = module.cluster.cluster_certificate_authority_data
}