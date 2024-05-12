module "efs" {
  source = "../../../../../external/efs"

  name        = var.efs_name
  encrypted   = true
  kms_key_arn = var.kms_key_arn

  throughput_mode = "elastic"
  attach_policy   = false

  mount_targets = { for k, v in zipmap(var.azs, var.private_subnets) : k => { subnet_id = v } }

  security_group_name        = "${var.efs_name}-efs"
  security_group_description = "${var.efs_name} security group  to control the traffic to the EFS and allow only Kubernetes nodes"
  security_group_vpc_id      = var.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description              = "NFS ingress from EKS cluster primary security group"
      source_security_group_id = var.whitelisted_sg
    }
  }

  tags = var.cost_tags
}
