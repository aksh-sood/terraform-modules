output "cluster" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "EKS cluster version provisioned"
  value       = module.eks.cluster_version
}

output "cluster_cert" {
value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}