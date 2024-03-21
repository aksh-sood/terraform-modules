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


data "cloudflare_zone" "this" {

  provider = cloudflare.this

  name = var.domain_name
}

resource "cloudflare_record" "cnames" {
  count = length(var.cnames)

  provider = cloudflare.this

  name    = "${var.environment}-${var.cnames[count.index]}"
  zone_id = data.cloudflare_zone.this.id
  type    = "CNAME"
  proxied = true
  value   = var.loadbalancer_url
}