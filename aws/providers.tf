terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.20.1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = var.enable_client_vpn ? var.client_vpn_metadata_bucket_region:var.region
  alias  = "vpn"
}