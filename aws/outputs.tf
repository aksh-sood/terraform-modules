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

output "efs_id" {
  description = "EFS volume ID for EKS Cluster"
  value       = var.create_eks ? module.eks[0].efs_id : null
}

output "acm_certificate_arn" {
  description = "ARN of the domain certificate"
  value       = module.domain_certificate.certificate_arn
}

output "grafana_role_arn" {
  description = "role arn id for cloudwatch datasource in grafana"
  value       = var.create_eks ? module.eks[0].grafana_role_arn : null
}


output "opensearch_endpoint" {
  value = module.opensearch[0].endpoint
}

output "opensearch_password" {
  value = module.opensearch[0].password
  sensitive = true
}

output "opensearch_username" {
  value = module.opensearch[0].username
}