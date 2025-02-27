variable "tag_specifications" {
  default = ["instance", "volume", "network-interface"]
}

variable "ssh_key" {}
variable "cluster_name" {}
variable "node_security_group_id" {}
variable "primary_security_group_id" {}
variable "node_role_arn" {}
variable "name" {}
variable "subnet_ids" {}
variable "min_size" {}
variable "max_size" {}
variable "desired_size" {}
variable "instance_types" {}
variable "labels" {}
variable "tags" {}
variable "cortex_agent_tags" {}
variable "block_device_mappings" {}
variable "cluster_version" {}