# provider "aws" {
#   region = var.region
# }

provider "kubernetes" {
  config_path = "~/.kube/${var.environment}"
}

provider "helm" {
  kubernetes {
  config_path = "~/.kube/${var.environment}"
  }
}