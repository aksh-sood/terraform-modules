
data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "sftp_host" {
  name        = "SFTP-HOST-${var.region}"
  description = "SFTP HOST for ${var.region}"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "eks_ingress_whitelist" {
  type                     = "ingress"
  from_port                = 20
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sftp_host.id
  source_security_group_id = var.eks_security_group
}

resource "aws_security_group_rule" "eks_egress_whitelist" {
  type                     = "egress"
  from_port                = 20
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sftp_host.id
  source_security_group_id = var.eks_security_group
}

resource "aws_security_group_rule" "sftp_ingress_whitelist" {
  for_each = toset(var.ingress_whitelist)

  type              = "ingress"
  from_port         = 20
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.sftp_host.id
  cidr_blocks       = [each.key]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  public_key = trimspace(tls_private_key.ssh_key.public_key_openssh)

  key_name = "sftp-host-${var.region}"

  provisioner "local-exec" {
    command = <<-EOT
    echo '${trimspace(tls_private_key.ssh_key.private_key_pem)}' > ${pathexpand("~/sftp-host-${var.region}.pem")};
    echo '${trimspace(tls_private_key.ssh_key.public_key_openssh)}' > ${pathexpand("~/sftp-host-${var.region}.pub")};
    EOT
  }

  tags = var.tags
}

resource "aws_instance" "sftp_proxy" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name                = aws_key_pair.generated_key.key_name
  security_groups         = [aws_security_group.sftp_host.id]
  subnet_id               = var.subnet_id
  disable_api_termination = var.disable_api_termination
  disable_api_stop        = var.disable_api_stop
  monitoring              = var.enable_monitoring

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted  = true
    kms_key_id = var.kms_key_id
  }

  tags = merge({ Name = "SFTP host" }, var.tags)

  lifecycle {
    ignore_changes = [security_groups, metadata_options]
  }
}

resource "aws_eip" "sftp_proxy" {
  domain   = "vpc"
  instance = aws_instance.sftp_proxy.id

  tags = var.tags
}


# Saving SSH keys in S3 bucket
resource "aws_s3_object" "eks_nodes_public_key" {
  bucket = var.keys_s3_bucket
  key    = "sftp-host-${var.region}.pub"
  source = pathexpand("~/sftp-host-${var.region}.pub")

  depends_on = [aws_key_pair.generated_key]
}

resource "aws_s3_object" "eks_nodes_private_key" {
  bucket = var.keys_s3_bucket
  key    = "sftp-host-${var.region}.pem"
  source = pathexpand("~/sftp-host-${var.region}.pem")

  depends_on = [aws_key_pair.generated_key]
}