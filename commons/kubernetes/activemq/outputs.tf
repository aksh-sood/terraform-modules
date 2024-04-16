output "url" {
  value = ["${var.namespace}-activemq.${var.domain_name}"]
}

output "password" {
  value = random_password.password.result
}