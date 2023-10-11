terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.10.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/${var.environment}"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${var.environment}"
  }
}

