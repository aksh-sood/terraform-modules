output "vpc_id" {
  description = "VPC id of the cluster"
  value       = module.vpc.id
}

output "public_subnet_ids" {
  description = "public subnets of the cluster"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "private subnets of the cluster"
  value       = module.vpc.private_subnets
}

output "kms_key_arn" {
  description = "ARN of KMS key created"
  value       = module.kms.key_arn
}

output "efs_id" {
  description = "EFS volume ID for EKS Cluster"
  value       = var.create_eks ? module.eks[0].efs_id : null
}

output "eks_security_group" {
  description = "secuirty group attached to both cluster and nodes"
  value       = var.create_eks ? module.eks[0].primary_security_group_id : null
}

output "elb_security_group" {
  description = "Security Group for Load balancers"
  value       = var.create_eks ? module.eks[0].elb_security_group : null
}

output "internal_alb_security_group" {
  description = "Security group for Private Load Balancers"
  value       = var.create_eks ? module.eks[0].internal_alb_security_group : null
}

output "vpn_security_group" {
  description = "Security Group for VPN"
  value       = var.enable_client_vpn ? module.client_vpn[0].security_group : null
}

output "acm_certificate_arn" {
  description = "ARN of the domain certificate"
  value       = var.create_certificate ? module.domain_certificate[0].certificate_arn : null
}

output "grafana_role_arn" {
  description = "role arn id for cloudwatch datasource in grafana"
  value       = var.create_eks ? module.eks[0].grafana_role_arn : null
}

output "curator_iam_role_arn" {
  value = var.create_eks ? module.opensearch[0].curator_iam_role_arn : null
}

output "curator_iam_user_arn" {
  value = var.create_eks ? module.opensearch[0].curator_iam_user_arn : null
}

output "curator_iam_user_access_key" {
  value     = var.create_eks ? module.opensearch[0].curator_iam_user_access_key : null
  sensitive = true
}

output "curator_iam_user_secret_key" {
  value     = var.create_eks ? module.opensearch[0].curator_iam_user_secret_key : null
  sensitive = true
}

output "s3_bucket_for_curator" {
  value = var.create_s3_bucket_for_curator ? module.s3_for_curator[0].id : null
}


output "opensearch_endpoint" {
  value = var.create_eks ? module.opensearch[0].endpoint : null
}

output "opensearch_password" {
  sensitive = true
  value     = var.create_eks ? module.opensearch[0].password : null
}

output "opensearch_username" {
  value = var.create_eks ? module.opensearch[0].username : null
}

output "eks_node_role_arn" {
  value = var.create_eks ? module.eks[0].node_role_arn : null
}

output "eks_cluster_role_arn" {
  value = var.create_eks ? module.eks[0].cluster_role_arn : null
}

output "keys_s3_bucket" {
  value = var.create_eks ? module.secrets_bucket[0].id : null
}

output "waf_arn" {
  description = "ARN of the WAF"
  value       = var.enable_waf ? module.waf[0].arn : null
}
