locals {
  node_groups_list = lookup(var.eks_node_groups, "node_groups", var.node_groups)

  # Terraform uses the key name to maintain the state of objects when having a loop on a resource and prevents
  # any changes to the infrastructure with the same key name even if their index changes in a list.
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
  lbc_version  = var.lbc_version
  efs_version  = var.efs_version

  depends_on = [module.cluster, module.eks_node, module.iam]
}

module "istio" {
  source = "./modules/istio"

  acm_certificate_arn    = var.acm_certificate_arn
  siem_storage_s3_bucket = var.siem_storage_s3_bucket
  istio_version          = var.istio_version

  depends_on = [module.addons, module.eks_node, module.iam]
}
