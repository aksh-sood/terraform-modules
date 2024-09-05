data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_security_group" "nlb" {
  name        = "${var.name}-rabbitmq-nlb"
  description = "Security Group for Network Load Balancer for RabbitMQ"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "whitelisting_custom_ips_to_5671" {
  to_port           = "5671"
  from_port         = "5671"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = var.whitelist_ips
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelisting_vpc_to_5671" {
  to_port           = "5671"
  from_port         = "5671"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.nlb.id
}


resource "aws_security_group_rule" "whitelisting_custom_ips_to_443" {
  to_port           = "443"
  from_port         = "443"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [var.whitelist_ips]
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelisting_vpc_to_443" {
  to_port           = "443"
  from_port         = "443"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelisting_rabbitmq" {
  to_port           = "0"
  from_port         = "0"
  type              = "ingress"
  protocol          = "-1"
  cidr_blocks       = [var.rabbitmq_sg]
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelisting_eks" {
  to_port           = "0"
  from_port         = "0"
  type              = "ingress"
  protocol          = "-1"
  cidr_blocks       = [var.eks_security_group]
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelisting_eks" {
  to_port           = "0"
  from_port         = "0"
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = [var.rabbitmq_sg]
  security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "whitelist_nlb_to_rabbitmq" {
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
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


#Attaching the target group to the RabbitMQ instance
resource "aws_lb_target_group_attachment" "rabbitmq_5671_target_group" {
  target_group_arn = aws_lb_target_group.rabbitmq_5671_target_group.arn
  target_id        = var.rabbitmq_private_ip
  port             = 5671
}


#Creating a Network Load Balancer
resource "aws_lb" "network_load_balancer" {
  name               = "${var.name}-rabbitmq-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.nlb.id]

}


#Creating a listener on the NLB's port 5671, forwarding traffic to the target group.
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
