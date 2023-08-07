output "vpc_id" {
  description = "VPC id of the cluster"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "public subnets of the cluster"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "private subnets of the cluster"
  value       = module.vpc.private_subnets
}