provider "aws" {
  region = var.region
}

# # This provider generates a default config file for the cluster for authentication 
# provider "kubernetes" {
#   host                   = var.create_eks ? module.eks[0].cluster_endpoint : null
#   cluster_ca_certificate = var.create_eks ? base64decode(module.eks[0].cluster_certificate_authority_data) : null
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", var.environment]
#   }
# }

# # This provider is used for the installation of helm addon installtions and requries the authentication to cluster 
# provider "helm" {
#   kubernetes {
#     host                   = var.create_eks ? module.eks[0].cluster_endpoint : null
#     cluster_ca_certificate = var.create_eks ? base64decode(module.eks[0].cluster_certificate_authority_data) : null
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", var.environment]
#     }
#   }
# }

