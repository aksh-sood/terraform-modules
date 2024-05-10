# eks cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.20.0
  version = "19.20.0"

  cluster_name    = var.cluster_name
  cluster_version = try(var.cluster_version, null)

  # IAM role for cluster
  create_iam_role = false
  iam_role_arn    = var.cluster_role_arn
  enable_irsa     = false

  #VPC configuration
  vpc_id     = var.vpc_id
  subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)

  #prefix configuration
  cluster_security_group_use_name_prefix    = false
  node_security_group_use_name_prefix       = false
  iam_role_use_name_prefix                  = false
  cluster_encryption_policy_use_name_prefix = false

  # security groups
  cluster_security_group_additional_rules = {
    elb_whitelist_80 = {
      type                       = "ingress"
      from_port                  = 80
      to_port                    = 80
      protocol                   = "tcp"
      source_security_group_id=var.elb_security_group
    }
    elb_whitelist_443 = {
      type                       = "ingress"
      from_port                  = 443
      to_port                    = 443
      protocol                   = "tcp"
      source_security_group_id=var.elb_security_group
    }
  }
  create_node_security_group = false

  #public and private access for cluster endpoint
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  #logging
  cluster_enabled_log_types = [ "audit", "api", "authenticator", "controllerManager", "scheduler"]

  #configuration of kms key  
  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }

  #Tags related to all the componets created through this module
  tags = var.eks_tags

}

resource "aws_security_group_rule" "cluster_egress_block" {
  type                     = "egress"
  protocol                 = "-1"
  to_port                  = 0
  from_port                = 0
  source_security_group_id = module.eks.cluster_primary_security_group_id
  security_group_id        = module.eks.cluster_primary_security_group_id
}

#fetching kube config file from aws
resource "null_resource" "cluster_config_pull" {
  provisioner "local-exec" {
    command = <<-EOT
    aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name} --kubeconfig ~/.kube/${var.cluster_name}
    export KUBECONFIG=$KUBECONFIG:~/.kube/${var.cluster_name}
    EOT
  }

  depends_on = [module.eks]
}