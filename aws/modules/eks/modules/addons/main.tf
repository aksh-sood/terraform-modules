#installing aws eks drivers
resource "aws_eks_addon" "this" {
  for_each     = toset(concat(var.eks_addons, var.additional_eks_addons))
  cluster_name = var.cluster_name
  addon_name   = each.key
}