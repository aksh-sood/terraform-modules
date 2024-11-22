resource "random_password" "activemq_password" {
  length      = 16
  special     = false
  lower       = true
  min_lower   = 1
  numeric     = true
  min_numeric = 1
  upper       = true
  min_upper   = 1
}

resource "aws_security_group" "activemq_sg" {
  name        = "Activemq-${var.name}-${var.region}"
  description = "Activemq Security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-activemq" })
}

resource "aws_security_group_rule" "security_group_whitelist_61617" {
  type                     = "ingress"
  from_port                = 61617
  to_port                  = 61617
  protocol                 = "tcp"
  source_security_group_id = var.whitelist_security_groups
  security_group_id        = aws_security_group.activemq_sg.id
}

resource "aws_security_group_rule" "security_group_whitelist_8162" {
  type                     = "ingress"
  from_port                = 8162
  to_port                  = 8162
  protocol                 = "tcp"
  source_security_group_id = var.whitelist_security_groups
  security_group_id        = aws_security_group.activemq_sg.id
}

resource "aws_security_group_rule" "ingress_whitelisted_ips_port_61617" {
  for_each = toset(var.ingress_whitelist_ips)

  type              = "ingress"
  from_port         = 61617
  to_port           = 61617
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.activemq_sg.id
}

resource "aws_security_group_rule" "ingress_whitelisted_ips_port_8162" {
  for_each = toset(var.ingress_whitelist_ips)

  type              = "ingress"
  from_port         = 8162
  to_port           = 8162
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.activemq_sg.id
}

resource "aws_security_group_rule" "egress_whitelisted_ips_port_61617" {
  for_each = toset(var.egress_whitelist_ips)

  type              = "egress"
  from_port         = 61617
  to_port           = 61617
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.activemq_sg.id
}

resource "aws_security_group_rule" "egress_whitelisted_ips_port_8162" {
  for_each = toset(var.egress_whitelist_ips)

  type              = "egress"
  from_port         = 8162
  to_port           = 8162
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.activemq_sg.id
}

resource "aws_mq_configuration" "mq_configuration" {
  name           = "${var.name}-activemq"
  description    = "ActiveMQ for ${var.name}"
  engine_type    = "ActiveMQ"
  engine_version = var.engine_version
  data           = file("${path.module}/config.xml")

  # The ignore lifecycle block is added to ignore changes to ActiveMQ configuration 
  # as it always generates a change in plan whenever triggered which can cause conflict with GITOPS model
  lifecycle {
    ignore_changes = [
      data
    ]
  }
}

resource "aws_mq_broker" "activemq" {
  broker_name = "activemq-${var.name}"

  configuration {
    id = aws_mq_configuration.mq_configuration.id
  }

  logs {
    audit   = true
    general = true
  }

  engine_type                = "ActiveMQ"
  engine_version             = var.engine_version
  storage_type               = var.storage_type
  host_instance_type         = var.instance_type
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = var.publicly_accessible
  subnet_ids                 = var.subnet_ids
  security_groups            = [aws_security_group.activemq_sg.id]
  deployment_mode            = var.deployment_mode

  user {
    console_access = true
    username       = var.username
    password       = random_password.activemq_password.result
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [engine_version]
  }

}
