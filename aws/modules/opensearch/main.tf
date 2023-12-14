resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "sg" {
  name        = "${var.domain_name}-opensearch"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [var.eks_sg]
  }
}

resource "aws_opensearch_domain" "domain" {
    domain_name = var.domain_name
    engine_version = "OpenSearch_2.7"

    cluster_config {
      instance_type = var.instance_type
      instance_count = var.instance_count
    }

    ebs_options {
      ebs_enabled = true
      volume_size = var.ebs_volume
    }
    node_to_node_encryption {
      enabled = true
    }
    advanced_security_options {
      enabled = true
      internal_user_database_enabled = true
      master_user_options {
        master_user_name = "master"
        master_user_password = random_password.password.result
      }
    }

    encrypt_at_rest {
      enabled = true
      kms_key_id = var.kms_key_arn
    }

    tags = {
    "Terraform" = true
    "Environment" = "${var.domain_name}"
    }

    vpc_options {
      security_group_ids = [aws_security_group.sg.id]
      subnet_ids = [var.subnet_ids[2]]
    }

    domain_endpoint_options {
      enforce_https = true
      tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
    }
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["${aws_opensearch_domain.domain.arn}/*"]

  }
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.domain.domain_name
  access_policies = data.aws_iam_policy_document.main.json
}