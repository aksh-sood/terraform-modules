variable "cost_tags" {
  type        = map(string)
  description = "Cost tags to be applied to transit gateways"
}

variable "amazon_side_asn" {
  type        = number
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session"
  default     = 64512
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether DNS support is enabled"
  default     = true
}

variable "enable_vpn_ecmp_support" {
  type        = bool
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled"
  default     = true
}

variable "central_vpc_id" {
  type        = string
  description = "ID of the central VPC"
}

variable "central_vpc_subnet_ids" {
  type        = list(string)
  description = "List of subnet CIDRs in the central VPC"
}

# Define the AWS accounts with which the Transit Gateways will be shared
variable "shared_accounts" {
  type    = list(string)
  default = [] # Set to empty list if no accounts are shared
}

variable "region_routes" {
  type = map(list(string))
  default = {
    "us-east-1"      = [],
    "us-west-2"      = [],
    "ap-southeast-1" = [],
    "eu-west-1"      = []
  }
}

variable "dr_central_vpc_id" {
  type        = string
  description = "ID of the DR central VPC"
}

variable "dr_central_vpc_subnet_ids" {
  type        = list(string)
  description = "List of subnet CIDRs in the DR central VPC"
}
