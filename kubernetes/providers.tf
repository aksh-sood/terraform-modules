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
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.environment]
    command     = "aws"
  }
}

# provider "kubernetes" {
#   config_path = "~/.kube/${var.environment}-${var.region}"
# }

# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/${var.environment}-${var.region}"
#   }
# }

provider "helm" {
  kubernetes {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.environment]
    command     = "aws"
  }
}
}

# provider "kubectl" {
#   config_path = "~/.kube/${var.environment}-${var.region}"
#   alias       = "this"
# }

provider "kubectl" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.environment]
    command     = "aws"
  }
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
