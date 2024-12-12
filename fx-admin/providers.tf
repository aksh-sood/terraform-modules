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

provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

provider "kubernetes" {
  config_path = "~/.kube/${var.k8s_cluster_name}-${var.region}"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${var.k8s_cluster_name}-${var.region}"
  }
}

provider "kubectl" {
  config_path = "~/.kube/${var.k8s_cluster_name}-${var.region}"
  alias       = "this"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
  alias     = "this"
}

provider "http" {}

# Below providers are for transit gateway

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}
