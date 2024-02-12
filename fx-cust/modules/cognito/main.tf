terraform {
  required_providers {
    validation = {
      source                = "tlkamp/validation"
      version               = "1.1.1"
      configuration_aliases = [validation.this]
    }
  }
}

locals {
  callback_urls = length(var.callback_prefix) > 0 ? [for cp in var.callback_prefix : "https://${cp}.${var.domain_name}/modules/login/callback.html"] : null
  logout_urls   = length(var.logout_prefix) > 0 ? [for lp in var.logout_prefix : "https://${lp}.${var.domain_name}/modules/login/login.html"] : null
}

resource "aws_cognito_user_pool" "this" {
  name                     = var.name
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  schema {
    name                = "node"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "roles"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  username_attributes = ["email"]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = split(".", var.domain_name)[0]
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_ui_customization" "this" {
  css        = file("${path.module}/templates/custom-css.css")
  image_file = filebase64("${path.module}/templates/image.jpg")

  # user_pool_id attribute to ensure it is in an 'Active' state
  user_pool_id = aws_cognito_user_pool_domain.this.user_pool_id
}

resource "validation_warning" "warn" {
  condition = length(var.callback_prefix) == 0
  summary   = "var.callback_prefix is empty. Hence App Integrations for cognito are not created"
  details   = <<EOF
callback_prefix needs to be set with minimum one value for AWS Cognito app integrations to be created. 
You can either provide the value or create it post application deployment and configuration .
EOF
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  count = length(var.callback_prefix) > 0 ? 1 : 0

  name         = var.name
  user_pool_id = aws_cognito_user_pool_domain.this.user_pool_id

  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors        = "ENABLED"
  callback_urls                        = local.callback_urls
  logout_urls                          = local.logout_urls
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}


