# Transit Gateway Network Configuration

This Terraform configuration sets up a hub-and-spoke network architecture using AWS Transit Gateways across multiple regions (us-east-1, us-west-2, and ap-southeast-1). It creates Transit Gateways, peering connections between them, and configures routing tables to enable communication between VPCs in different regions.

## Features

- Creates Transit Gateways in three regions
- Establishes peering connections between Transit Gateways
- Configures routing tables for inter-region communication
- Attaches a central VPC to the Transit Gateway in us-east-1
- Optionally shares Transit Gateways with other AWS accounts

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| **central_vpc_id** * | ID of the central VPC | `string` | n/a |
| **central_vpc_subnet_ids** * | List of subnet CIDRs in the central VPC | `list(string)` | n/a |
| amazon_side_asn | Private Autonomous System Number (ASN) for the Amazon side of a BGP session | `number` | `64512` |
| enable_dns_support | Whether DNS support is enabled | `bool` | `true` |
| enable_vpn_ecmp_support | Whether VPN Equal Cost Multipath Protocol support is enabled | `bool` | `true` |
| region_routes | Map of CIDR blocks for each region | `map(list(string))` | `{"us-east-1": [], "us-west-2": [], "ap-southeast-1": []}` |
| shared_accounts | List of AWS account IDs to share Transit Gateways with | `list(string)` | `[]` |
| **cost_tags** * | Cost tags to be applied to transit gateways | `map(string)` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| transit_gateway_ids | Map of region to Transit Gateway ID |
| transit_gateway_peering_attachment_ids | List of Transit Gateway Peering Attachment IDs |

## Example Usage

```hcl
module "transit_gateway_network" {
  source = "./path/to/module"

  central_vpc_id         = "vpc-1234567890abcdef0"
  central_vpc_subnet_ids = ["subnet-1234567890abcdef0", "subnet-0987654321fedcba0"]
  amazon_side_asn        = 64512
  enable_dns_support     = true
  enable_vpn_ecmp_support = true

  region_routes = {
    "us-east-1"      = ["10.0.0.0/16", "10.1.0.0/16"]
    "us-west-2"      = ["10.2.0.0/16", "10.3.0.0/16"]
    "ap-southeast-1" = ["10.4.0.0/16", "10.5.0.0/16"]
  }

  shared_accounts = ["123456789012", "210987654321"]

  cost_tags = {
    Environment = "Production"
    Project     = "NetworkInfrastructure"
  }
}
```

## Note

- The central VPC should be in the us-east-1 region.
