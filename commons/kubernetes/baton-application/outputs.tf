output "host" {
  value = var.subdomain_suffix == "" ? "${var.namespace}.${var.domain_name}" : "${var.namespace}-${var.subdomain_suffix}.${var.domain_name}"
}