locals {
  eks_private_subnet_tags = var.create_eks ? {
    "kubernetes.io/cluster/${var.environment}" = "owned"
    "kubernetes.io/role/internal-elb"          = "1"
  } : {}
  eks_public_subnet_tags = var.create_eks ? {
    "kubernetes.io/cluster/${var.environment}" = "owned"
    "kubernetes.io/role/elb"                   = "1"
  } : {}
}

locals {
  key_user_arns = var.create_eks ? [
    module.eks[0].cluster_role_arn, module.eks[0].node_role_arn
  ] : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
}