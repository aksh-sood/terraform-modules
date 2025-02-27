# This Terraform configuration file sets up Transit Gateways and their associated resources
# across multiple AWS regions. It creates a hub-and-spoke network architecture with peering
# between Transit Gateways in different regions.
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">=2.7.0"
      configuration_aliases = [aws.us-east-1, aws.us-west-2, aws.ap-southeast-1, aws.eu-west-1]
    }
  }
}
data "aws_caller_identity" "current" {}

data "aws_vpc" "central_vpc" {
  id = var.central_vpc_id
}

data "aws_route_table" "subnet_route_tables" {
  for_each  = toset(var.central_vpc_subnet_ids)
  subnet_id = each.value
}

locals {
  unique_route_table_ids = distinct([
    for rt in values(data.aws_route_table.subnet_route_tables) : rt.route_table_id
  ])

  us_east_1_routes = concat([data.aws_vpc.central_vpc.cidr_block], var.region_routes["us-east-1"])
  us_west_2_routes = concat([data.aws_vpc.dr_central_vpc.cidr_block], var.region_routes["us-west-2"])
  updated_region_routes = merge(var.region_routes, {
    "us-east-1" = local.us_east_1_routes,
    "us-west-2" = local.us_west_2_routes
  })
}

# Fetch DR VPC subnet route table IDs
data "aws_route_table" "dr_subnet_route_tables" {
  for_each  = toset(var.dr_central_vpc_subnet_ids)
  subnet_id = each.value
  provider  = aws.us-west-2
}

locals {
  dr_unique_route_table_ids = distinct([
    for rt in values(data.aws_route_table.dr_subnet_route_tables) : rt.route_table_id
  ])
}

data "aws_vpc" "dr_central_vpc" {
  id       = var.dr_central_vpc_id
  provider = aws.us-west-2
}

# Create Transit Gateways in each specified region
resource "aws_ec2_transit_gateway" "tgw_us_east_1" {
  description                     = "Transit Gateway for us-east-1"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-us-east-1"
    }
  )

  provider = aws.us-east-1
}

resource "aws_ec2_transit_gateway" "tgw_us_west_2" {
  description                     = "Transit Gateway for us-west-2"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-us-west-2"
    }
  )

  provider = aws.us-west-2
}
resource "aws_ec2_transit_gateway" "tgw_ap_southeast_1" {
  description                     = "Transit Gateway for ap-southeast-1"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-ap-southeast-1"
    }
  )

  provider = aws.ap-southeast-1
}

resource "aws_ec2_transit_gateway" "tgw_eu_west_1" {
  description                     = "Transit Gateway for eu-west-1"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-eu-west-1"
    }
  )

  provider = aws.eu-west-1
}

# Create route tables for each Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "peering_us_east_1" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_us_east_1.id

  tags = {
    Name = "Peering-RT-us-east-1"
  }

  provider = aws.us-east-1
}

resource "aws_ec2_transit_gateway_route_table" "peering_us_west_2" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_us_west_2.id

  tags = {
    Name = "Peering-RT-us-west-2"
  }

  provider = aws.us-west-2
}

resource "aws_ec2_transit_gateway_route_table" "peering_ap_southeast_1" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_ap_southeast_1.id

  tags = {
    Name = "Peering-RT-ap-southeast-1"
  }

  provider = aws.ap-southeast-1
}

resource "aws_ec2_transit_gateway_route_table" "peering_eu_west_1" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_eu_west_1.id

  tags = {
    Name = "Peering-RT-eu-west-1"
  }

  provider = aws.eu-west-1
}

# Create peering connections between Transit Gateways in different regions
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_us_east_1_us_west_2" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-west-2"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_us_west_2.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_us_east_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-us-east-1-us-west-2"
    }
  )

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway.tgw_us_east_1, aws_ec2_transit_gateway.tgw_us_west_2]
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_us_east_1_ap_southeast_1" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "ap-southeast-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_ap_southeast_1.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_us_east_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-us-east-1-ap-southeast-1"
    }
  )

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway.tgw_us_east_1, aws_ec2_transit_gateway.tgw_ap_southeast_1]
}
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_us_east_1_eu_west_1" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "eu-west-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_eu_west_1.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_us_east_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-us-east-1-eu-west-1"
    }
  )

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway.tgw_us_east_1, aws_ec2_transit_gateway.tgw_eu_west_1]
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_eu_west_1_ap_southeast_1" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "ap-southeast-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_ap_southeast_1.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_eu_west_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-eu-west-1-ap-southeast-1"
    }
  )

  provider   = aws.eu-west-1
  depends_on = [aws_ec2_transit_gateway.tgw_eu_west_1, aws_ec2_transit_gateway.tgw_ap_southeast_1]
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_eu_west_1_us_west_2" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-west-2"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_us_west_2.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_eu_west_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-eu-west-1-us-west-2"
    }
  )

  provider   = aws.eu-west-1
  depends_on = [aws_ec2_transit_gateway.tgw_eu_west_1, aws_ec2_transit_gateway.tgw_us_west_2]
}

resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_us_west_2_ap_southeast_1" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "ap-southeast-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_ap_southeast_1.id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_us_west_2.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-us-west-2-ap-southeast-1"
    }
  )

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway.tgw_us_west_2, aws_ec2_transit_gateway.tgw_ap_southeast_1]
}

# Accept peering connections
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter_us_west_2_us_east_1" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-Accepter-us-west-2-us-east-1"
    }
  )

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter_ap_southeast_1_us_east_1" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-Accepter-ap-southeast-1-us-east-1"
    }
  )

  provider   = aws.ap-southeast-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter_ap_southeast_1_us_west_2" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-Accepter-ap-southeast-1-us-west-2"
    }
  )

  provider   = aws.ap-southeast-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter_eu_west_1_us_east_1" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-Accepter-eu-west-1-us-east-1"
    }
  )

  provider   = aws.eu-west-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter_us_west_2_eu_west_1" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-Accepter-us-west-2-eu-west-1"
    }
  )

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter_ap_southeast_1_eu_west_1" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1.id

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Peering-Accepter-ap-southeast-1-eu-west-1"
    }
  )

  provider   = aws.ap-southeast-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1]
}

# Create a wait resource
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_east_1,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_west_2,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_eu_west_1_us_east_1,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_eu_west_1
  ]
}
# Associate peering connections with peering route table
resource "aws_ec2_transit_gateway_route_table_association" "peering_us_east_1_us_west_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2, aws_ec2_transit_gateway_route_table.peering_us_east_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_us_east_1_ap_southeast_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1, aws_ec2_transit_gateway_route_table.peering_us_east_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_us_west_2_us_east_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1, aws_ec2_transit_gateway_route_table.peering_us_west_2]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_us_west_2_ap_southeast_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1, aws_ec2_transit_gateway_route_table.peering_us_west_2]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_ap_southeast_1_us_east_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_ap_southeast_1.id

  provider   = aws.ap-southeast-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_east_1, aws_ec2_transit_gateway_route_table.peering_ap_southeast_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_ap_southeast_1_us_west_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_ap_southeast_1.id

  provider   = aws.ap-southeast-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_west_2, aws_ec2_transit_gateway_route_table.peering_ap_southeast_1]
}
resource "aws_ec2_transit_gateway_route_table_association" "peering_us_east_1_eu_west_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1, aws_ec2_transit_gateway_route_table.peering_us_east_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_eu_west_1_us_east_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_eu_west_1_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_eu_west_1.id

  provider   = aws.eu-west-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_eu_west_1_us_east_1, aws_ec2_transit_gateway_route_table.peering_eu_west_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_eu_west_1_us_west_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_eu_west_1.id

  provider   = aws.eu-west-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2, aws_ec2_transit_gateway_route_table.peering_eu_west_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_eu_west_1_ap_southeast_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_eu_west_1.id

  provider   = aws.eu-west-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1, aws_ec2_transit_gateway_route_table.peering_eu_west_1]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_us_west_2_eu_west_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1, aws_ec2_transit_gateway_route_table.peering_us_west_2]
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_ap_southeast_1_eu_west_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_ap_southeast_1.id

  provider   = aws.ap-southeast-1
  depends_on = [time_sleep.wait_30_seconds, aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_eu_west_1, aws_ec2_transit_gateway_route_table.peering_ap_southeast_1]
}

# Add routes to peering route tables
resource "aws_ec2_transit_gateway_route" "peering_rt_self_route" {
  destination_cidr_block         = data.aws_vpc.central_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "us_east_1_to_us_west_2" {
  for_each                       = toset(local.updated_region_routes["us-west-2"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "us_east_1_to_ap_southeast_1" {
  for_each                       = toset(local.updated_region_routes["ap-southeast-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "us_west_2_to_us_east_1" {
  for_each                       = toset(local.updated_region_routes["us-east-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "us_west_2_to_ap_southeast_1" {
  for_each                       = toset(local.updated_region_routes["ap-southeast-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "ap_southeast_1_to_us_east_1" {
  for_each                       = toset(local.updated_region_routes["us-east-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_ap_southeast_1.id

  provider   = aws.ap-southeast-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_east_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "ap_southeast_1_to_us_west_2" {
  for_each                       = toset(local.updated_region_routes["us-west-2"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_ap_southeast_1.id

  provider   = aws.ap-southeast-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_us_west_2, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "us_east_1_to_eu_west_1" {
  for_each                       = toset(local.updated_region_routes["eu-west-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_east_1.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "us_west_2_to_eu_west_1" {
  for_each                       = toset(local.updated_region_routes["eu-west-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "ap_southeast_1_to_eu_west_1" {
  for_each                       = toset(local.updated_region_routes["eu-west-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_ap_southeast_1.id

  provider   = aws.ap-southeast-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_ap_southeast_1_eu_west_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "eu_west_1_to_us_east_1" {
  for_each                       = toset(local.updated_region_routes["us-east-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_eu_west_1_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_eu_west_1.id

  provider   = aws.eu-west-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_eu_west_1_us_east_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "eu_west_1_to_us_west_2" {
  for_each                       = toset(local.updated_region_routes["us-west-2"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_eu_west_1.id

  provider   = aws.eu-west-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_us_west_2, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "eu_west_1_to_ap_southeast_1" {
  for_each                       = toset(local.updated_region_routes["ap-southeast-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_eu_west_1.id

  provider   = aws.eu-west-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_eu_west_1_ap_southeast_1, time_sleep.wait_30_seconds]
}


# Create Transit Gateway attachment for central VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "central_vpc_attachment" {
  subnet_ids         = var.central_vpc_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw_us_east_1.id
  vpc_id             = var.central_vpc_id

  tags = merge(
    var.cost_tags,
    {
      Name = "Central-VPC-TGW-Attachment"
    }
  )

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway.tgw_us_east_1, time_sleep.wait_30_seconds]
}

# Create Transit Gateway route table for central VPC attachment
resource "aws_ec2_transit_gateway_route_table" "central_vpc_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_us_east_1.id

  tags = {
    Name = "Central-VPC-RT"
  }

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway.tgw_us_east_1, time_sleep.wait_30_seconds]
}

# Associate central VPC attachment with its route table
resource "aws_ec2_transit_gateway_route_table_association" "central_vpc_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central_vpc_rt.id

  provider = aws.us-east-1
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment,
    aws_ec2_transit_gateway_route_table.central_vpc_rt,
    time_sleep.wait_30_seconds
  ]
}

# Propagate central VPC routes to its own TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "central_vpc_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central_vpc_rt.id

  provider = aws.us-east-1
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment,
    aws_ec2_transit_gateway_route_table.central_vpc_rt,
    time_sleep.wait_30_seconds
  ]
}

# Add routes to central VPC route table for all regions
resource "aws_ec2_transit_gateway_route" "central_vpc_to_us_west_2" {
  for_each                       = toset(local.updated_region_routes["us-west-2"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central_vpc_rt.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "central_vpc_to_ap_southeast_1" {
  for_each                       = toset(local.updated_region_routes["ap-southeast-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central_vpc_rt.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "central_vpc_to_eu_west_1" {
  for_each                       = toset(local.updated_region_routes["eu-west-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.central_vpc_rt.id

  provider   = aws.us-east-1
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1, time_sleep.wait_30_seconds]
}

# Add routes to VPC subnet route table for all regions
resource "aws_route" "vpc_to_tgw" {
  for_each = {
    for pair in flatten([
      for region, cidrs in var.region_routes : [
        for index, cidr in cidrs : [
          for route_table_id in local.unique_route_table_ids : {
            region         = region
            index          = index
            route_table_id = route_table_id
            cidr           = cidr
          }
        ]
      ]
    ]) : "${pair.region}-${pair.index}-${pair.route_table_id}" => pair
  }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_us_east_1.id

  provider = aws.us-east-1
  depends_on = [
    aws_ec2_transit_gateway.tgw_us_east_1,
    aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_ap_southeast_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_eu_west_1,
    time_sleep.wait_30_seconds
  ]
}

resource "aws_route" "vpc_to_dr_central_vpc" {
  for_each = toset(local.unique_route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = data.aws_vpc.dr_central_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_us_east_1.id

  provider = aws.us-east-1
  depends_on = [
    aws_ec2_transit_gateway.tgw_us_east_1,
    aws_ec2_transit_gateway_vpc_attachment.central_vpc_attachment,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_east_1_us_west_2,
    time_sleep.wait_30_seconds
  ]
}

# Create Transit Gateway attachment for DR central VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "dr_central_vpc_attachment" {
  subnet_ids         = var.dr_central_vpc_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw_us_west_2.id
  vpc_id             = var.dr_central_vpc_id

  tags = merge(
    var.cost_tags,
    {
      Name = "DR-Central-VPC-TGW-Attachment"
    }
  )

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway.tgw_us_west_2, time_sleep.wait_30_seconds]
}

# Create Transit Gateway route table for DR central VPC attachment
resource "aws_ec2_transit_gateway_route_table" "dr_central_vpc_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_us_west_2.id

  tags = {
    Name = "DR-Central-VPC-RT"
  }

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway.tgw_us_west_2, time_sleep.wait_30_seconds]
}

# Associate DR central VPC attachment with its route table
resource "aws_ec2_transit_gateway_route_table_association" "dr_central_vpc_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dr_central_vpc_rt.id

  provider = aws.us-west-2
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment,
    aws_ec2_transit_gateway_route_table.dr_central_vpc_rt,
    time_sleep.wait_30_seconds
  ]
}

# Propagate DR central VPC routes to its own TGW route table
resource "aws_ec2_transit_gateway_route_table_propagation" "dr_central_vpc_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dr_central_vpc_rt.id

  provider = aws.us-west-2
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment,
    aws_ec2_transit_gateway_route_table.dr_central_vpc_rt,
    time_sleep.wait_30_seconds
  ]
}

# Add dr central routes to peering route tables
resource "aws_ec2_transit_gateway_route" "peering_rt_dr_self_route" {
  destination_cidr_block         = data.aws_vpc.dr_central_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_us_west_2.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment, time_sleep.wait_30_seconds, aws_ec2_transit_gateway_route_table.peering_us_west_2]
}

# Add routes to DR central VPC route table for all regions
resource "aws_ec2_transit_gateway_route" "dr_central_vpc_to_us_east_1" {
  for_each                       = toset(local.updated_region_routes["us-east-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dr_central_vpc_rt.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "dr_central_vpc_to_ap_southeast_1" {
  for_each                       = toset(local.updated_region_routes["ap-southeast-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dr_central_vpc_rt.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1, time_sleep.wait_30_seconds]
}

resource "aws_ec2_transit_gateway_route" "dr_central_vpc_to_eu_west_1" {
  for_each                       = toset(local.updated_region_routes["eu-west-1"])
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dr_central_vpc_rt.id

  provider   = aws.us-west-2
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1, time_sleep.wait_30_seconds]
}

# Add routes to DR VPC subnet route table for all regions
resource "aws_route" "dr_vpc_to_tgw" {
  for_each = {
    for pair in flatten([
      for region, cidrs in var.region_routes : [
        for index, cidr in cidrs : [
          for route_table_id in local.dr_unique_route_table_ids : {
            region         = region
            index          = index
            route_table_id = route_table_id
            cidr           = cidr
          }
        ]
      ]
    ]) : "${pair.region}-${pair.index}-${pair.route_table_id}" => pair
  }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_us_west_2.id

  provider = aws.us-west-2
  depends_on = [
    aws_ec2_transit_gateway.tgw_us_west_2,
    aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1,
    aws_ec2_transit_gateway_peering_attachment.tgw_peering_us_west_2_ap_southeast_1,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_eu_west_1,
    time_sleep.wait_30_seconds
  ]
}

resource "aws_route" "dr_vpc_to_central_vpc" {
  for_each = toset(local.dr_unique_route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = data.aws_vpc.central_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_us_west_2.id

  provider = aws.us-west-2
  depends_on = [
    aws_ec2_transit_gateway.tgw_us_west_2,
    aws_ec2_transit_gateway_vpc_attachment.dr_central_vpc_attachment,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter_us_west_2_us_east_1,
    time_sleep.wait_30_seconds
  ]
}

# Create Resource Shares only if shared accounts are provided
resource "aws_ram_resource_share" "tgw_share_us_east_1" {
  count                     = length(var.shared_accounts) > 0 ? 1 : 0
  name                      = "TGW-Share-us-east-1"
  allow_external_principals = true

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Share-us-east-1"
    }
  )

  provider = aws.us-east-1
}

resource "aws_ram_resource_association" "tgw_share_association_us_east_1" {
  count              = length(var.shared_accounts) > 0 ? 1 : 0
  resource_share_arn = aws_ram_resource_share.tgw_share_us_east_1[0].arn
  resource_arn       = aws_ec2_transit_gateway.tgw_us_east_1.arn

  provider   = aws.us-east-1
  depends_on = [aws_ram_resource_share.tgw_share_us_east_1]
}

resource "aws_ram_principal_association" "tgw_principal_association_us_east_1" {
  for_each           = toset(var.shared_accounts)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw_share_us_east_1[0].arn

  provider = aws.us-east-1
}

resource "aws_ram_resource_share" "tgw_share_us_west_2" {
  count                     = length(var.shared_accounts) > 0 ? 1 : 0
  name                      = "TGW-Share-us-west-2"
  allow_external_principals = true

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Share-us-west-2"
    }
  )

  provider = aws.us-west-2
}

resource "aws_ram_resource_association" "tgw_share_association_us_west_2" {
  count              = length(var.shared_accounts) > 0 ? 1 : 0
  resource_share_arn = aws_ram_resource_share.tgw_share_us_west_2[0].arn
  resource_arn       = aws_ec2_transit_gateway.tgw_us_west_2.arn

  provider   = aws.us-west-2
  depends_on = [aws_ram_resource_share.tgw_share_us_west_2]
}

resource "aws_ram_principal_association" "tgw_principal_association_us_west_2" {
  for_each           = toset(var.shared_accounts)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw_share_us_west_2[0].arn

  provider = aws.us-west-2
}

resource "aws_ram_resource_share" "tgw_share_ap_southeast_1" {
  count                     = length(var.shared_accounts) > 0 ? 1 : 0
  name                      = "TGW-Share-ap-southeast-1"
  allow_external_principals = true

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Share-ap-southeast-1"
    }
  )

  provider = aws.ap-southeast-1
}

resource "aws_ram_resource_association" "tgw_share_association_ap_southeast_1" {
  count              = length(var.shared_accounts) > 0 ? 1 : 0
  resource_share_arn = aws_ram_resource_share.tgw_share_ap_southeast_1[0].arn
  resource_arn       = aws_ec2_transit_gateway.tgw_ap_southeast_1.arn

  provider   = aws.ap-southeast-1
  depends_on = [aws_ram_resource_share.tgw_share_ap_southeast_1]
}

resource "aws_ram_principal_association" "tgw_principal_association_ap_southeast_1" {
  for_each           = toset(var.shared_accounts)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw_share_ap_southeast_1[0].arn

  provider = aws.ap-southeast-1
}

resource "aws_ram_resource_share" "tgw_share_eu_west_1" {
  count                     = length(var.shared_accounts) > 0 ? 1 : 0
  name                      = "TGW-Share-eu-west-1"
  allow_external_principals = true

  tags = merge(
    var.cost_tags,
    {
      Name = "TGW-Share-eu-west-1"
    }
  )

  provider = aws.eu-west-1
}

resource "aws_ram_resource_association" "tgw_share_association_eu_west_1" {
  count              = length(var.shared_accounts) > 0 ? 1 : 0
  resource_share_arn = aws_ram_resource_share.tgw_share_eu_west_1[0].arn
  resource_arn       = aws_ec2_transit_gateway.tgw_eu_west_1.arn

  provider   = aws.eu-west-1
  depends_on = [aws_ram_resource_share.tgw_share_eu_west_1]
}

resource "aws_ram_principal_association" "tgw_principal_association_eu_west_1" {
  for_each           = toset(var.shared_accounts)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw_share_eu_west_1[0].arn

  provider = aws.eu-west-1
}
