data "aws_caller_identity" "current" {}

module "kms" {
  source = "terraform-aws-modules/kms/aws"
  # https://registry.terraform.io/modules/terraform-aws-modules/kms/aws/2.1.0
  version = "2.1.0"

  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_users                 = var.key_user_arns
  key_service_roles_for_autoscaling = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
  aliases                           = ["${var.alias}-${var.environment}"]

  tags = var.kms_tags
}

resource "aws_ebs_default_kms_key" "key_set" {
  key_arn = module.kms.key_arn
}