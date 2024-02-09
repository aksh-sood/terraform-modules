variable "cnames" {
  type    = list(string)
  default = ["prometheus", "grafana", "alertmanager", "kibana"]
}
variable "loadbalancer_url" {}
variable "environment" {}
variable "domain_name" {}