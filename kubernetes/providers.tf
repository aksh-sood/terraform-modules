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
    helm = {
      source  = "hashicorp/helm"
      version = "=2.10.1"
    }
    # opensearch = {
    #   source  = "opensearch-project/opensearch"
    #   version = "2.3.0"
    #   configuration_aliases = [opensearch.this]
    # }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/${var.environment}"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/${var.environment}"
  }
}

provider "kubectl" {
  config_path = "~/.kube/${var.environment}"
  alias       = "this"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
  alias     = "this"
}

# provider "opensearch" {
#   url                = "https://${var.opensearch_endpoint}:443"
#   aws_region         = var.region
#   username           = var.opensearch_username
#   password           = var.opensearch_password
#   healthcheck        = false
#   sign_aws_requests  = false
#   opensearch_version = 2.11
# }