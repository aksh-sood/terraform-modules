variable "ram_principals" {
  description = "List of accounts to which tgw needs to be shared"
  type        = list(number)
  default     = []
}
variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "tags" {}