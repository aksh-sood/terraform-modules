locals {
  node_groups_list = lookup(var.eks_node_groups, "node_groups", var.node_groups)

  # By converting the list to map, we use the keys instead of the indexes from the list
  # for maintenance of terraform state and resources created.
  # This makes the entire state management order independent i.e the user can insert or delete
  # a resource configuration anywhere in the list without affecting other resources.
  # It also increases the readability, dependency management and maintenance of the infrastructure.
  node_groups_map = {
    for ng in local.node_groups_list :
    ng.name => ng
  }
}

resource "aws_security_group" "elb_sg" {
  name        = "ELB-${var.cluster_name}-${var.region}"
  description = "ELB Security group for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = merge(var.eks_tags, { Name = "${var.cluster_name}-elb" })
}

resource "aws_security_group_rule" "ingress_security_group_whitelist_80" {
  for_each = toset(var.alb_ingress_whitelist)

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "ingress_security_group_whitelist_443" {
  for_each = toset(var.alb_ingress_whitelist)

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "egress_security_group_whitelist_80" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.cluster.primary_security_group_id
  security_group_id        = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "egress_security_group_whitelist_443" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.cluster.primary_security_group_id
  security_group_id        = aws_security_group.elb_sg.id
}

resource "aws_security_group" "internal_alb_sg" {
  name        = "Internal-ALB-${var.cluster_name}-${var.region}"
  description = "Internal ALB Security group for ${var.cluster_name}"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.cluster.primary_security_group_id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.cluster.primary_security_group_id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(var.eks_tags, { Name = "${var.cluster_name}-elb" })
}

resource "aws_security_group_rule" "internal_alb_to_vpn_sg_whitelisting" {
  count                    = var.enable_client_vpn ? 1 : 0
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.internal_alb_sg.id
  source_security_group_id = var.vpn_security_group

}

resource "aws_security_group_rule" "eks_to_internal_alb_whitelisting" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.cluster.primary_security_group_id
  source_security_group_id = aws_security_group.internal_alb_sg.id
}


module "iam" {
  source = "./modules/iam"

  cluster_name                  = var.cluster_name
  region                        = var.region
  additional_node_policies      = coalesce(var.eks_node_groups.additional_node_policies, [])
  additional_node_inline_policy = var.eks_node_groups.additional_node_inline_policy
  mount_point_s3_bucket_name    = var.mount_point_s3_bucket_name
  tags                          = var.eks_tags
}

module "cluster" {
  source = "./modules/cluster"

  cluster_role_arn   = module.iam.cluster_role_arn
  elb_security_group = aws_security_group.elb_sg.id

  region                    = var.region
  cluster_version           = var.cluster_version
  cluster_name              = var.cluster_name
  vpc_id                    = var.vpc_id
  vpc_cidr                  = var.vpc_cidr
  private_subnet_ids        = var.private_subnet_ids
  public_subnet_ids         = var.public_subnet_ids
  kms_key_arn               = var.kms_key_arn
  eks_tags                  = var.eks_tags
  eks_ingress_whitelist_ips = var.eks_ingress_whitelist_ips
  eks_public_access         = var.eks_public_access
  eks_public_access_ips     = var.eks_public_access_ips
  secrets_key_bucket_name   = var.secrets_key_bucket_name

  depends_on = [module.iam]
}

#Resource to create a SSH private key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  public_key = trimspace(tls_private_key.ssh_key.public_key_openssh)

  key_name = "${var.cluster_name}-eks-nodes"
  tags     = var.eks_tags

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_key.private_key_pem}' > ${pathexpand("~/${var.cluster_name}-eks-nodes.pem")}"
  }
}

#This resources saves the private key to access EKS nodes
resource "aws_s3_object" "eks_nodes_private_key" {
  bucket = var.secrets_key_bucket_name
  key    = "${var.cluster_name}-eks-nodes.pem"
  source = pathexpand("~/${var.cluster_name}-eks-nodes.pem")

  depends_on = [aws_key_pair.generated_key]
}

module "eks_node" {
  source   = "./modules/nodes"
  for_each = { for k, v in local.node_groups_map : k => v }

  node_role_arn             = module.iam.node_role_arn
  primary_security_group_id = module.cluster.primary_security_group_id
  cluster_version           = module.cluster.cluster_version
  ssh_key                   = aws_key_pair.generated_key.key_name

  cluster_name = var.cluster_name
  subnet_ids   = var.private_subnet_ids

  name = each.value.name

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = try(var.eks_node_groups.volume_size, 20)
        volume_type           = try(var.eks_node_groups.volume_type, "gp3")
        encrypted             = true
        kms_key_id            = var.kms_key_arn
        delete_on_termination = true
      }
    }
  }

  max_size     = try(each.value.max_size, 5)
  desired_size = try(each.value.min_size, 1)
  min_size     = try(each.value.min_size, 1)

  instance_types = try(each.value.instance_types, ["m5.large"])
  cortex_agent_tags = try(each.value.cortex_agent_tags, "")

  labels = try(each.value.labels, {})

  node_security_group_id = try(each.value.additional_security_groups, [])


  tags = try(merge(var.eks_tags, each.value.tags), var.eks_tags, var.enable_cluster_autoscaler ? { "k8s.io/cluster-autoscaler/enabled" = true } : {})
}

module "addons" {
  source = "./modules/addons"

  cluster_name          = var.cluster_name
  eks_addons            = var.eks_addons
  additional_eks_addons = var.additional_eks_addons

  depends_on = [module.cluster, module.eks_node, module.iam]
}

module "efs" {
  source = "./modules/efs"

  efs_name             = var.cluster_name
  kms_key_arn          = var.kms_key_arn
  vpc_id               = var.vpc_id
  azs                  = var.azs
  private_subnets      = var.private_subnet_ids
  private_subnets_cidr = var.private_subnets_cidr
  cost_tags            = var.eks_tags
  whitelisted_sg       = module.cluster.primary_security_group_id
}
