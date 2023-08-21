# EFS driver installation
resource "helm_release" "efs_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = var.efs_version

  values = [
    <<-EOT
replicaCount: 1 
storageClasses:
  - name: efs-sc
    reclaimPolicy: Retain
    parameters:
      provisioningMode: efs-ap
      fileSystemId: ${var.efs_id}
      directoryPerms: "700"
EOT      
  ]
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

}

