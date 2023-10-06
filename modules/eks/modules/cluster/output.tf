output "cluster" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "cluster_endpoint" {
  description = "API endpoint for the cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "AWS Clutser certificate"
  value       = module.eks.cluster_certificate_authority_data
}