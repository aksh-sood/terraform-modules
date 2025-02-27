data "aws_vpc" "this" {
  id = var.vpc_id
}

locals {
  rabbitmq_endpoint = try(
    regex("(?:https?|amqps)://([^/:]+)(?::\\d+)?", var.rabbitmq_endpoint)[0],
    trimsuffix(var.rabbitmq_endpoint, "/")
  )

  ip_addresses = data.dns_a_record_set.rabbitmq.addrs

  target_private_ips = {
    for idx in range(3) :
    "ip-${idx + 1}" => try(local.ip_addresses[idx], null)
    if try(local.ip_addresses[idx], null) != null
  }
}


data "dns_a_record_set" "rabbitmq" {
  host = local.rabbitmq_endpoint
}

resource "aws_security_group" "nlb" {
  name        = "${var.name}-rabbitmq-nlb"
  description = "Security Group for Network Load Balancer for RabbitMQ"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "whitelisting_custom_ips_to_5671" {
  for_each = toset(var.whitelist_ips)

  to_port           = "5671"
  from_port         = "5671"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelisting_vpc_to_5671" {
  to_port           = "5671"
  from_port         = "5671"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.nlb.id

  lifecycle {
    ignore_changes = [cidr_blocks]
  }
}

resource "aws_security_group_rule" "whitelisting_vpc_on_nlb_on_443" {
  to_port           = "443"
  from_port         = "443"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.nlb.id

  lifecycle {
    ignore_changes = [cidr_blocks]
  }
}

resource "aws_security_group_rule" "whitelisting_rabbitmq" {
  to_port                  = 5671
  from_port                = 5671
  type                     = "ingress"
  protocol                 = "tcp"
  source_security_group_id = var.rabbitmq_sg
  security_group_id        = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelist_nlb_to_rabbitmq_5671" {
  to_port                  = 5671
  from_port                = 5671
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = var.rabbitmq_sg
  security_group_id        = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelist_nlb_to_rabbitmq_443" {
  to_port                  = 443
  from_port                = 443
  type                     = "egress"
  protocol                 = "tcp"
  source_security_group_id = var.rabbitmq_sg
  security_group_id        = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelist_nlb_on_rabbitmq" {
  from_port                = 5671
  to_port                  = 5671
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = var.rabbitmq_sg
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_lb_target_group" "rabbitmq_5671_target_group" {
  name        = "${var.name}-rabbitmq-tg"
  port        = 5671
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    port                = 443
    protocol            = "HTTPS"
    path                = "/"
    unhealthy_threshold = 2
    healthy_threshold   = 5
    timeout             = 10
    interval            = 30
  }
}

resource "aws_lb_target_group_attachment" "rabbitmq_5671_target_group" {
  for_each = var.rabbitmq_cluster_mode == true ? {
    "ip_1" = try(local.target_private_ips["ip-1"], null)
    "ip_2" = try(local.target_private_ips["ip-2"], null)
    "ip_3" = try(local.target_private_ips["ip-3"], null)
    } : {
    "ip_1" = try(local.target_private_ips["ip-1"], null)
  }

  target_group_arn = aws_lb_target_group.rabbitmq_5671_target_group.arn
  target_id        = each.value
  port             = 5671

}

resource "aws_lb" "network_load_balancer" {
  name               = "${var.name}-rabbitmq-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.nlb.id]

  tags = var.tags
}

resource "aws_lb_listener" "rabbitmq_5671_listener" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = 5671
  protocol          = "TLS"
  certificate_arn   = var.public_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rabbitmq_5671_target_group.arn
  }
}
