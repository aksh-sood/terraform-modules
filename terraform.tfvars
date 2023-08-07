region = "us-east-1"

environment = "test"

vpc_cidr = "10.0.0.0/16"

public_subnet_tags = {}

private_subnet_tags = {}

cost_tags = {
  env-type    = "test"
  customer    = "internal"
  cost-center = "overhead"
}

vpc_tags = {
  Purpose = "Automation using terraform"
}

az_count = 3

enable_nat_gateway = true

public_subnets_cidr = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

private_subnets_cidr = ["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]

siem_storage_s3_bucket = "eks-auto-vpc-flow-logs"