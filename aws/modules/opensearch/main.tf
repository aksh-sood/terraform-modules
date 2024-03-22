resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_special      = 1
  lower            = true
  min_lower        = 1
  numeric          = true
  min_numeric      = 1
  upper            = true
  min_upper        = 1
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
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
  }
  node_to_node_encryption {
    enabled = true
  }

  advanced_options = {
    override_main_response_version : true
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_username
      master_user_password = random_password.password.result
    }
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn
  }

  tags = merge(var.cost_tags, {
    "Terraform"   = true
    "Environment" = "${var.domain_name}"
  })

  # TODO: Multi-AZ Implementation

  # OpenSearch Terraform resource requires the following for Multi-AZ setup
  # Ensure that instance_count aligns with the number of AZs
  # For 2 AZs, requires instance_count as multiples of 2; for 3 AZs, multiples of 3
  # Distribute subnets to match the instance count's
  # Aim for a more straightforward and reliable Multi-AZ implementation without unnecessary complexity
  vpc_options {
    security_group_ids = [aws_security_group.sg.id]
    subnet_ids         = [var.subnet_ids[0]]
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
}

resource "time_sleep" "domain_policy" {
  create_duration = "5m"

  depends_on = [ aws_opensearch_domain.domain ]
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.domain.domain_name
  access_policies = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "es:*",
      "Resource": "${aws_opensearch_domain.domain.arn}/*"
    }
  ]
}
EOF

  depends_on = [time_sleep.domain_policy]
}
