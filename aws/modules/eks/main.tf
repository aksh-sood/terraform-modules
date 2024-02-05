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

module "iam" {
  source = "./modules/iam"

  cluster_name                  = var.cluster_name
  region                        = var.region
  additional_node_policies      = coalesce(var.eks_node_groups.additional_node_policies, [])
  additional_node_inline_policy = var.eks_node_groups.additional_node_inline_policy
  tags                          = var.eks_tags
}

module "cluster" {
  source = "./modules/cluster"

  cluster_role_arn = module.iam.cluster_role_arn

  region             = var.region
  cluster_version    = var.cluster_version
  cluster_name       = var.cluster_name
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  kms_key_arn        = var.kms_key_arn
  eks_tags           = var.eks_tags

  depends_on = [module.iam]
}

#Resource to create a SSH private key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  public_key = tls_private_key.ssh_key.public_key_openssh

  key_name = "${var.cluster_name}-eks-nodes"
  tags     = var.eks_tags

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh_key.private_key_pem}' > ./${var.cluster_name}-eks-nodes.pem"
  }
}

module "eks_node" {
  source   = "./modules/nodes"
  for_each = { for k, v in local.node_groups_map : k => v }

  primary_security_group_id = module.cluster.primary_security_group_id
  node_role_arn             = module.iam.node_role_arn
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

  labels = try(each.value.labels, {})

  node_security_group_id = try(each.value.additional_security_groups, [])


  tags = try(merge(var.eks_tags, each.value.tags), var.eks_tags)
}

module "addons" {
  source = "./modules/addons"

  cluster_name = var.cluster_name
  eks_addons   = var.eks_addons
  additional_eks_addons  = var.additional_eks_addons

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