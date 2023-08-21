data "aws_caller_identity" "current" {}

# handles the creation of VPC and its components for cluster creation
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr               = var.vpc_cidr
  enable_nat_gateway     = var.enable_nat_gateway
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  az_count               = var.az_count
  region                 = var.region
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  cost_tags              = var.cost_tags
  vpc_tags               = merge(var.vpc_tags, { Name = var.environment })
  public_subnet_tags     = merge(var.public_subnet_tags, local.eks_public_subnet_tags)
  private_subnet_tags    = merge(var.private_subnet_tags, local.eks_private_subnet_tags)
}

module "domain_certificate" {
  source = "./modules/domain-certificate"

  acm_certificate_bucket = var.acm_certificate_bucket
  public_key             = var.acm_certificate
  cert_key               = var.acm_certificate_chain
  pem_key                = var.acm_private_key

  acm_tags = var.cost_tags
}

resource "aws_ebs_encryption_by_default" "default_encrypt" {
  enabled = true
}

module "kms" {
  source = "./modules/kms"

  key_user_arns = local.key_user_arns

  kms_tags = var.cost_tags

  depends_on = [aws_ebs_encryption_by_default.default_encrypt]
}

module "eks" {
  source = "./modules/eks"
  count  = var.create_eks ? 1 : 0

  vpc_id              = module.vpc.id
  private_subnet_ids  = module.vpc.private_subnets
  public_subnet_ids   = module.vpc.public_subnets
  kms_key_arn         = module.kms.key_arn
  acm_certificate_arn = module.domain_certificate.certificate_arn

  region          = var.region
  cluster_name    = var.environment
  cluster_version = var.cluster_version
  istio_version   = var.istio_version
  eks_node_groups = var.eks_node_groups
  eks_tags        = var.cost_tags

  depends_on = [module.vpc]
}