data "aws_availability_zones" "this" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "null_resource" "azs_list_validation" {
  lifecycle {
    precondition {
      condition     = length(data.aws_availability_zones.this.names) >= var.az_count
      error_message = "Provided regions doesn't have the minimum of ${var.az_count} availability zone"
    }
  }
}

resource "null_resource" "siem_validation" {
  lifecycle {
    precondition {
      condition     = var.enable_siem ? (var.siem_storage_s3_bucket != "" && var.siem_storage_s3_bucket != null) : true
      error_message = "Provide siem_storage_s3_bucket or disable enable_siem"
    }
  }
}

module "vpc" {
  source = "../../../external/vpc"

  azs  = slice(data.aws_availability_zones.this.names, 0, var.az_count)
  cidr = var.vpc_cidr

  # private subnet config
  private_subnets     = var.private_subnet_cidrs
  private_subnet_tags = merge(var.cost_tags, var.private_subnet_tags)
  private_subnet_tags_per_az = {
    for az in slice(data.aws_availability_zones.this.names,0,var.az_count) : az => {
      Name = "${var.name}-private-subnet-${az}"
    }
  }

  # public subnet config
  map_public_ip_on_launch = false
  public_subnets          = var.public_subnet_cidrs
  public_subnet_tags      = merge(var.cost_tags, var.public_subnet_tags)
  public_subnet_tags_per_az = {
     for az in slice(data.aws_availability_zones.this.names,0,var.az_count) : az => {
      Name = "${var.name}-public-subnet-${az}"
    }
  }

  # NAT gateway config
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.enable_nat_gateway
  one_nat_gateway_per_az = false
  nat_gateway_tags       = merge(var.cost_tags, { Name = var.name })

  # Internet Gateway config
  igw_tags = var.cost_tags

  # Route Table config
  public_route_table_tags  = merge(var.cost_tags, var.public_route_table_tags)
  private_route_table_tags = merge(var.cost_tags, var.private_route_table_tags)

  #vpc flow logging
  enable_flow_log           = var.enable_siem ? true : false
  flow_log_destination_type = var.enable_siem ? "s3" : null
  flow_log_destination_arn  = var.enable_siem ? "arn:aws:s3:::${var.siem_storage_s3_bucket}" : null
  vpc_flow_log_tags         = var.enable_siem ? merge(var.cost_tags, var.vpc_flow_log_tags) : null

  #default acl configuration
  default_network_acl_ingress = var.default_acl_ingress_rules
  default_network_acl_egress  = var.default_acl_egress_rules

  #private network acl 
  private_dedicated_network_acl = true

  private_inbound_acl_rules  = concat(var.common_acl_ingress_rules, var.private_acl_ingress_rules)
  private_outbound_acl_rules = concat(var.common_acl_egress_rules, var.private_acl_egress_rules)

  #public network acl
  public_dedicated_network_acl = true

  public_inbound_acl_rules  = concat(var.common_acl_ingress_rules, var.public_acl_ingress_rules)
  public_outbound_acl_rules = concat(var.common_acl_egress_rules, var.public_acl_egress_rules)

  tags = merge(var.cost_tags, var.vpc_tags, { Name = var.name })

  depends_on = [null_resource.azs_list_validation, null_resource.siem_validation]
}

# setting the ingress, egress rules of default security group created by vpc module to null 
# this resource is required because of the default rules set in the vpc module for deault security group 
# due to which we cannot make the ingress and egress as null 
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id

  tags = merge(var.cost_tags, var.vpc_tags, { Name = var.name })
}