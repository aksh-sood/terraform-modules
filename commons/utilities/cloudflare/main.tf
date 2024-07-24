terraform {
  required_version = ">= 0.13"

  required_providers {
    cloudflare = {
      source                = "cloudflare/cloudflare"
      version               = "~> 4.0"
      configuration_aliases = [cloudflare.this]
    }
  }
}

locals {
  cnames = toset([for c in var.cnames : c != "" ? "-${c}" : c])
}

data "cloudflare_zone" "this" {

  provider = cloudflare.this

  name = var.domain_name
}

resource "cloudflare_record" "cnames" {
  for_each = local.cnames

  provider = cloudflare.this

  name    = "${var.name}${each.key}"
  zone_id = data.cloudflare_zone.this.id
  type    = "CNAME"
  proxied = true
  value   = var.loadbalancer_url
}
