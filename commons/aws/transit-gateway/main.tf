module "tgw" {
  source = "../../../external/tgw"

  name        = var.name
  description = "Transit Gateway for ${var.name}"

  enable_auto_accept_shared_attachments = false
  enable_multicast_support              = false

  vpc_attachments = {
    vpc = {
      vpc_id       = var.vpc_id
      subnet_ids   = var.subnet_ids
      dns_support  = true
      ipv6_support = false

    }
  }

  create_tgw_routes = false

  ram_allow_external_principals = true
  ram_principals                = var.ram_principals

  tags = var.tags
}
