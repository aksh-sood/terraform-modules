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
  region = var.enable_client_vpn ? var.client_vpn_metadata_bucket_region : var.region
  alias  = "vpn"
}

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