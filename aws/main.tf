data "aws_caller_identity" "current" {}

# This resource to validates existence of service roles for autoscaling and opensearch
resource "null_resource" "service_roles_validation" {
  provisioner "local-exec" {
    command = <<-EOT
    aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com >>/dev/null 2>&1 || true
    aws iam create-service-linked-role --aws-service-name opensearchservice.amazonaws.com >>/dev/null 2>&1 || true
    EOT
  }
}

resource "null_resource" "vpn_validation" {
  lifecycle {
    precondition {
      condition = var.enable_client_vpn ? (
        var.client_vpn_metadata_bucket_region != "" && var.client_vpn_metadata_bucket_region != null &&
        var.client_vpn_metadata_bucket_name != "" && var.client_vpn_metadata_bucket_name != null &&
        var.client_vpn_metadata_object_key != "" && var.client_vpn_metadata_object_key != null
      ) : true
      error_message = "Provide client_vpn_metadata_bucket_region, client_vpn_metadata_bucket_name, client_vpn_metadata_object_key or disable enable_client_vpn"
    }
  }

  depends_on = [null_resource.service_roles_validation]
}

resource "null_resource" "certificate_validation" {
  lifecycle {
    precondition {
      condition = !var.create_certificate ? (
      var.acm_certificate_arn != "" && var.acm_certificate_arn != null) : true
      error_message = "Provide acm_certificate_arn or set create_certificate to true"
    }
  }
}

module "security_hub" {
  source = "./modules/security-hub"
  count  = var.subscribe_security_hub ? 1 : 0

  region                         = var.region
  security_hub_standards         = var.security_hub_standards
  disabled_security_hub_controls = local.disabled_security_hub_controls
}

module "vpc" {
  source = "./modules/vpc"

  name                   = var.environment
  enable_siem            = var.enable_siem
  vpc_cidr               = var.vpc_cidr
  enable_nat_gateway     = var.enable_nat_gateway
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  region                 = var.region
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  cost_tags              = var.cost_tags
  az_count               = local.az_count
  vpc_tags               = var.vpc_tags
  public_subnet_tags     = merge(var.public_subnet_tags, local.eks_public_subnet_tags)
  private_subnet_tags    = merge(var.private_subnet_tags, local.eks_private_subnet_tags)
}

module "domain_certificate" {
  source = "./modules/domain-certificate"
  count  = var.create_certificate ? 1 : 0

  acm_certificate_bucket = var.acm_certificate_bucket
  certificate            = var.acm_certificate
  cert_chain             = var.acm_certificate_chain
  private_key            = var.acm_private_key
  providers = {
    aws.east = aws.east
  }

  acm_tags = var.cost_tags
}

resource "aws_ebs_encryption_by_default" "default_encrypt" {
  enabled = true
}

module "client_vpn" {
  source = "./modules/vpn-endpoint"
  count  = var.enable_client_vpn ? 1 : 0

  vpc_id    = module.vpc.id
  subnet_id = module.vpc.private_subnets[0]

  name                     = var.environment
  target_network_cidr      = var.vpc_cidr
  access_group_id          = var.client_vpn_access_group_id
  saml_metadata_bucket     = var.client_vpn_metadata_bucket_name
  enable_split_tunnel      = var.enable_client_vpn_split_tunneling
  saml_metadata_object_key = var.client_vpn_metadata_object_key
  acm_certificate_arn      = var.create_certificate ? module.domain_certificate[0].certificate_arn : var.acm_certificate_arn

  cost_tags = var.cost_tags

  providers = {
    aws.this = aws.vpn
  }

  depends_on = [null_resource.vpn_validation, null_resource.certificate_validation]
}

module "kms" {
  source = "./modules/kms"

  key_user_arns = local.key_user_arns

  environment = var.environment
  kms_tags    = var.cost_tags

  depends_on = [aws_ebs_encryption_by_default.default_encrypt]
}

module "eks" {
  source = "./modules/eks"
  count  = var.create_eks ? 1 : 0

  vpc_id             = module.vpc.id
  azs                = module.vpc.azs
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets
  kms_key_arn        = module.kms.key_arn

  region                     = var.region
  vpc_cidr                   = var.vpc_cidr
  cluster_name               = var.environment
  cluster_version            = var.cluster_version
  eks_node_groups            = var.eks_node_groups
  siem_storage_s3_bucket     = var.siem_storage_s3_bucket
  private_subnet_cidrs       = var.private_subnet_cidrs
  private_subnets_cidr       = var.private_subnet_cidrs
  alb_ingress_whitelist      = var.alb_ingress_whitelist
  additional_eks_addons      = var.additional_eks_addons
  enable_cluster_autoscaler  = var.enable_cluster_autoscaler
  eks_ingress_whitelist_ips  = var.eks_ingress_whitelist_ips
  eks_public_access          = var.eks_public_access
  eks_public_access_ips      = var.eks_public_access ? var.eks_public_access_ips : []
  mount_point_s3_bucket_name = var.mount_point_s3_bucket_name
  enable_client_vpn          = var.enable_client_vpn
  vpn_security_group         = var.enable_client_vpn ? module.client_vpn[0].security_group : null

  eks_tags = var.cost_tags

  depends_on = [module.vpc]
}

module "opensearch" {
  source = "./modules/opensearch"
  count  = var.create_eks ? 1 : 0

  vpc_id      = module.vpc.id
  subnet_ids  = module.vpc.public_subnets
  kms_key_arn = module.kms.key_arn
  eks_sg      = var.create_eks ? module.eks[0].primary_security_group_id : null

  domain_name     = var.environment
  engine_version  = var.opensearch_engine_version
  instance_type   = var.opensearch_instance_type
  instance_count  = var.opensearch_instance_count
  ebs_volume_size = var.opensearch_ebs_volume_size
  master_username = var.opensearch_master_username
  cost_tags       = var.cost_tags
}
