#installing aws eks drivers
resource "aws_eks_addon" "this" {
  for_each     = var.eks_addons
  cluster_name = var.cluster_name
  addon_name   = each.key
}