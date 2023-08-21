locals {
  azs = formatlist("${var.region}%s", slice(var.az_code, 0, var.az_count))
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  azs  = local.azs
  cidr = var.vpc_cidr

  # private subnet config
  private_subnets     = var.private_subnet_cidrs
  private_subnet_tags = merge(var.cost_tags, var.private_subnet_tags)
  private_subnet_tags_per_az = {
    for az in local.azs : az => {
      Name = "Private Subnet - ${az}"
    }
  }

  # public subnet config
  map_public_ip_on_launch = false
  public_subnets          = var.public_subnet_cidrs
  public_subnet_tags      = merge(var.cost_tags, var.public_subnet_tags)
  public_subnet_tags_per_az = {
    for az in local.azs : az => {
      Name = "Public Subnet - ${az}"
    }
  }

  # NAT gateway config
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.enable_nat_gateway
  one_nat_gateway_per_az = false
  nat_gateway_tags       = var.cost_tags

  # Internet Gateway config
  igw_tags = var.cost_tags

  # Route Table config
  public_route_table_tags  = merge(var.cost_tags, var.public_route_table_tags)
  private_route_table_tags = merge(var.cost_tags, var.private_route_table_tags)

  #vpc flow logging
  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = "arn:aws:s3:::${var.siem_storage_s3_bucket}"
  vpc_flow_log_tags         = merge(var.cost_tags, var.vpc_flow_log_tags)

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

  tags = merge(var.cost_tags, var.vpc_tags)

}