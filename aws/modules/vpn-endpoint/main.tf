terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "=5.20.1"
      configuration_aliases = [aws.this]
    }
  }
}

data "aws_s3_object" "saml_metadata_document" {

  provider = aws.this

  bucket = var.saml_metadata_bucket
  key    = "/${var.saml_metadata_object_key}"
}

resource "aws_cloudwatch_log_group" "vpn_logs" {
  name              = "/aws/vpc/clientvpn"
  retention_in_days = 0

  tags = var.cost_tags
}

resource "aws_security_group" "client_vpn" {
  name   = "${var.name}-vpn-endpoint"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.cost_tags, { Name = "${var.name}-vpn-endpoint" })
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  security_group_ids     = [aws_security_group.client_vpn.id]
  server_certificate_arn = var.acm_certificate_arn
  client_cidr_block      = var.client_cidr_block
  vpc_id                 = var.vpc_id
  description            = "client VPN for ${var.name}"

  split_tunnel = var.enable_split_tunnel

  authentication_options {
    type              = "federated-authentication"
    saml_provider_arn = aws_iam_saml_provider.saml_provider.arn
  }

  connection_log_options {
    enabled              = true
    cloudwatch_log_group = aws_cloudwatch_log_group.vpn_logs.name
  }

  tags = merge(var.cost_tags, { Name = var.name })
}

resource "aws_ec2_client_vpn_network_association" "network_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "target_cidr_authorization" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.target_network_cidr
  access_group_id        = var.access_group_id
}

resource "aws_ec2_client_vpn_authorization_rule" "internet_authorization" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = "0.0.0.0/0"
  access_group_id        = var.access_group_id
}

resource "aws_iam_saml_provider" "saml_provider" {
  name                   = var.saml_provider_name
  saml_metadata_document = data.aws_s3_object.saml_metadata_document.body
  tags                   = var.cost_tags
}