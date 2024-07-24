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
    error_message = "Number should be greater than 0 and less than 6"
  }
}

variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_tags" {
  default = {}
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
    Description = "VPC Flow Log"
  }
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
  default = [{
    rule_number     = 403
    rule_action     = "deny"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 402
      rule_action = "deny"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 401
      rule_action     = "deny"
      from_port       = 3389
      to_port         = 3389
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 400
      rule_action = "deny"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 107
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 106
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_block  = "0.0.0.0/0"
      icmp_code   = 0
      icmp_type   = 8
    },
    {
      rule_number     = 105
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
      icmp_code       = 0
      icmp_type       = 8
    },
    {
      rule_number = 104
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 20
      to_port     = 65535
      protocol    = "udp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 102
      rule_action     = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "udp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 20
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 100
      rule_action     = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    }
  ]
}

variable "common_acl_egress_rules" {
  description = "base egress rules for all the NACl's"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 20
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 20
      to_port     = 65535
      protocol    = "udp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 103
      rule_action     = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "udp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 104
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 105
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_number = 106
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "icmp"
      cidr_block  = "0.0.0.0/0"
      icmp_code   = 0
      icmp_type   = 8
    },
    {
      rule_number     = 107
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
      icmp_code       = 0
      icmp_type       = 8
    }
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
      rule_no         = 403
      action          = "deny"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 402
      action     = "deny"
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 401
      action          = "deny"
      from_port       = 3389
      to_port         = 3389
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 400
      action     = "deny"
      from_port  = 3389
      to_port    = 3389
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 107
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
      icmp_code       = 0
      icmp_type       = 8
    },
    {
      rule_no    = 106
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "icmp"
      cidr_block = "0.0.0.0/0"
      icmp_code  = 0
      icmp_type  = 8
    },
    {
      rule_no         = 105
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 104
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "icmp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 103
      action     = "allow"
      from_port  = 20
      to_port    = 65535
      protocol   = "udp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 102
      action          = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "udp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 101
      action     = "allow"
      from_port  = 20
      to_port    = 65535
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 100
      action          = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    }
  ]
}

variable "default_acl_egress_rules" {
  description = "base egress rules for default NACL"
  type        = list(map(string))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 20
      to_port    = 65535
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 102
      action     = "allow"
      from_port  = 20
      to_port    = 65535
      protocol   = "udp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 103
      action          = "allow"
      from_port       = 20
      to_port         = 65535
      protocol        = "udp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 104
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "icmp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 105
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 106
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "icmp"
      cidr_block = "0.0.0.0/0"
      icmp_code  = 0
      icmp_type  = 8

    },
    {
      rule_no         = 107
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "icmp"
      ipv6_cidr_block = "::/0"
      icmp_code       = 0
      icmp_type       = 8

    }
  ]
}

variable "vpc_tags" {
  description = "tags for VPC and any related resources that do not have tags associated with them"
  type        = map(string)
}

variable "siem_storage_s3_bucket" {
  description = "ARN of the s3 bucket where logs are to be stored"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "list of public subnet cidr's to be created"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "list of private subnet cidr's to be created"
  type        = list(string)
}

variable "cost_tags" {}
variable "region" {}
variable "enable_nat_gateway" {}
variable "enable_siem" {}
variable "name" {}