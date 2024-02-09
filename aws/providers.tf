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