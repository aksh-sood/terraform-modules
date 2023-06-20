variable "cost_tags" {}
variable "region" {}
variable "enable_nat_gateway" {}

variable "vpc_cidr" {
  description = "vpc cidr range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "number of azs to provision subnets in"
  type        = number
  validation {
    condition     = var.az_count > 0 || var.az_count < 6
    error_message = "number should be a greater than 0 and less than 6"
  }
}

variable "az_code" {
  description = "alphbetic list of az codes"
  type        = list(string)
  default     = ["a", "b", "c", "d", "e", "f"]
}

variable "vpc_tags" {
  description = "tags for VPC and any related resources that do not have tags associated with them"
  type        = map(string)
}

variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_tags" {
  default = {}
}

variable "public_subnet_cidr" {
  description = "list of public subnet cidr's to be created"
  type        = list(string)
}
variable "private_subnet_cidr" {
  description = "list of private subnet cidr's to be created"
  type        = list(string)
}


variable "gateway_tags" {
  description = "Tags for internet gateway"
  type        = map(string)
  default = {
    Name = "VPC gateway"
  }
}

variable "nat_tags" {
  description = "Tags for nat gateway"
  type        = map(string)
  default = {
    Name = "Nat Gateway"
  }
}

variable "private_route_table_tags" {
  description = "Tags for private route table"
  type        = map(string)
  default = {
    Name = "Private Route Table"
  }
}

variable "public_route_table_tags" {
  description = "Tags for public route table"
  type        = map(string)
  default = {
    Name = "Public Route Table"
  }
}

variable "vpc_flow_log_tags" {
  description = "tags for vpc flow logging"
  type        = map(string)
  default = {
    Name = "VPC Flow Log"
  }
}

#flow logging

variable "siem_storage_s3_bucket" {
  description = "ARN of the s3 bucket where logs are to be stored"
  type        = string
}

#acl rules


variable "private_acl_egress_rules" {
  description = "base egress rules for private subnet NACL"
  type        = list(map(string))
  default     = []
}

#public acl rules 
variable "public_acl_ingress_rules" {
  description = "base ingress rules for public subnet NACL"
  type        = list(map(string))
  default     = []
}

variable "public_acl_egress_rules" {
  description = "base egress rules for public subnet NACL"
  type        = list(map(string))
  default     = []
}

variable "common_acl_ingress_rules" {
  description = "base ingress rules for both private and public NACl's"
  type        = list(map(string))
  default = [
    {
      rule_number     = 105
      rule_action     = "deny"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 104
      rule_action = "deny"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 103
      rule_action     = "deny"
      from_port       = 3389
      to_port         = 3389
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 102
      rule_action = "deny"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 100
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "common_acl_egress_rules" {
  description = "base egress rules for all the NACl's"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

#private acl rules
variable "private_acl_ingress_rules" {
  description = "base ingress rules for private subnet NACL"
  type        = list(map(string))
  default     = []
}

#default acl rules
variable "default_acl_ingress_rules" {
  description = "base ingress rules for default NACL"
  type        = list(map(string))
  default = [
    {
      rule_no         = 105
      action          = "deny"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 104
      action     = "deny"
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 103
      action          = "deny"
      from_port       = 3389
      to_port         = 3389
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 102
      action     = "deny"
      from_port  = 3389
      to_port    = 3389
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 101
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 100
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}

variable "default_acl_egress_rules" {
  description = "base egress rules for default NACL"
  type        = list(map(string))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}
