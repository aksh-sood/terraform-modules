data "aws_caller_identity" "current" {}


module "security_hub" {
  source = "./modules/security-hub"
  count  = var.subscribe_security_hub ? 1 : 0

  region                         = var.region
  security_hub_standards         = var.security_hub_standards
  disabled_security_hub_controls = local.disabled_security_hub_controls
}

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
  azs                 = module.vpc.azs
  private_subnet_ids  = module.vpc.private_subnets
  public_subnet_ids   = module.vpc.public_subnets
  kms_key_arn         = module.kms.key_arn
  acm_certificate_arn = module.domain_certificate.certificate_arn

  region                 = var.region
  cluster_name           = var.environment
  cluster_version        = var.cluster_version
  eks_node_groups        = var.eks_node_groups
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  private_subnet_cidrs   = var.private_subnet_cidrs
  eks_tags               = var.cost_tags
  private_subnets_cidr   = var.private_subnet_cidrs

  depends_on = [module.vpc]
}

module "opensearch" {
  source = "./modules/opensearch"
  count  = var.create_eks ? 1 : 0

  domain_name     = var.environment
  engine_version  = var.opensearch_engine_version
  vpc_id          = module.vpc.id
  subnet_ids      = module.vpc.public_subnets
  instance_type   = var.opensearch_instance_type
  instance_count  = var.opensearch_instance_count
  kms_key_arn     = module.kms.key_arn
  eks_sg          = module.eks[0].primary_security_group_id
  ebs_volume_size = var.opensearch_ebs_volume_size
  cost_tags       = var.cost_tags
}
