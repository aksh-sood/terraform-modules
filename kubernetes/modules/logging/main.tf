terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source                = "gavinbunney/kubectl"
      version               = ">= 1.7.0"
      configuration_aliases = [kubectl.this]}
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
      configuration_aliases = [ cloudflare.this ]
    }
  }
}

data "cloudflare_zone" "this" {
  provider = cloudflare.this
  name = var.domain_name
}

resource "cloudflare_record" "cnames" {
  provider = cloudflare.this
  name    = "${var.environment}-kibana"
  zone_id = data.cloudflare_zone.this.id
  type    = "CNAME"
  proxied = true
  value   = var.loadbalancer_url
}

module "filebeat" {
  source = "./modules/filebeat"

  opensearch_endpoint = var.opensearch_endpoint
  opensearch_username = var.opensearch_username
  opensearch_password = var.opensearch_password
  environment         = var.environment
  domain_name         = var.domain_name

  providers = {
    kubectl.this = kubectl.this
  }
}
