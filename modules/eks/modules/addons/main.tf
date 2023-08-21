#installing aws eks drivers
resource "aws_eks_addon" "this" {
  for_each     = var.eks_addons
  cluster_name = var.cluster_name
  addon_name   = each.key
}

# EFS driver installation
resource "helm_release" "efs_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = var.efs_version

  set {
    name  = "replicaCount"
    value = 1
  }
}

# Load balancer controller add on
resource "helm_release" "lbc_addon" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.lbc_version
  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  depends_on = [aws_eks_addon.this["coredns"]]
}

