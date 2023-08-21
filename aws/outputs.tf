output "azs" {
  description = "public subnets of the VPC"
  value       = module.vpc.azs
}

output "vpc_id" {
  description = "VPC id of the cluster"
  value       = module.vpc.id
}

output "public_subnets" {
  description = "public subnets of the cluster"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "private subnets of the cluster"
  value       = module.vpc.private_subnets
}

output "cluster_endpoint" {
  description = "API endpoint for the cluster"
  value       = try(module.eks.cluster_endpoint, null)
}

output "cluster_certificate_authority_data" {
  description = "AWS Clutser certificate"
  value       = try(module.eks.cluster_certificate_authority_data, null)
}

output "cluster_name" {
  description = "EKS Cluster name"
  value       = try(module.eks.cluster_name, null)
}

output "efs_id" {
  description = "EFS volume ID for EKS Cluster"
  value       = try(module.eks.efs_id, null)
}