locals {
  vpc_tags            = merge(var.vpc_tags, { Name = var.environment })
  public_subnet_tags  = merge(var.public_subnet_tags)
  private_subnet_tags = merge(var.private_subnet_tags)
}

# handles the creation of VPC and its components for cluster creation
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr               = var.vpc_cidr
  cost_tags              = var.cost_tags
  enable_nat_gateway     = var.enable_nat_gateway
  public_subnet_cidr     = var.public_subnets_cidr
  private_subnet_cidr    = var.private_subnets_cidr
  az_count               = var.az_count
  region                 = var.region
  vpc_tags               = local.vpc_tags
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  public_subnet_tags     = local.public_subnet_tags
  private_subnet_tags    = local.private_subnet_tags
}
