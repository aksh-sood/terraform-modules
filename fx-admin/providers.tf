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
      source                = "gavinbunney/kubectl"
      version               = ">= 1.7.0"
      configuration_aliases = [kubectl.this]
    }
    cloudflare = {
      source                = "cloudflare/cloudflare"
      version               = "~> 4.0"
      configuration_aliases = [cloudflare.this]
    }
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${var.k8s_cluster_name}"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/${var.k8s_cluster_name}"
}

provider "kubectl" {
  config_path = "~/.kube/${var.k8s_cluster_name}"
  alias       = "this"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
  alias     = "this"
}