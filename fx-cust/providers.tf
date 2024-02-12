terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.20.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    validation = {
      source  = "tlkamp/validation"
      version = "1.1.1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${var.environment}"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/${var.environment}"
}

provider "kubectl" {
  config_path = "~/.kube/${var.environment}"
  alias       = "this"
}

provider "validation" {
  alias = "this"
}