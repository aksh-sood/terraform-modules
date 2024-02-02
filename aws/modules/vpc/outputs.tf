output "azs" {
  description = "azs in which the vpc is provisioned"
  value       = module.vpc.azs
}

output "id" {
  description = "VPC id after creation "
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "public subnets of the VPC"
  value       = module.vpc.public_subnets
}


output "private_subnets" {
  description = "private subnets of the VPC"
  value       = module.vpc.private_subnets
}
