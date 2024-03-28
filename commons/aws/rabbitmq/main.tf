resource "random_password" "rabbitmq_password" {
  length           = 16
  special          = false
  lower            = true
  min_lower        = 1
  numeric          = true
  min_numeric      = 1
  upper            = true
  min_upper        = 1
}


resource "aws_security_group" "rabbitmq" {
  name        = "${var.name}-RabbitMQ"
  description = "RabbitMQ Security group for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = ""
    from_port       = 5671
    to_port         = 5671
    protocol        = "tcp"
    security_groups = var.whitelist_security_groups
  }

  ingress {
    description     = ""
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.whitelist_security_groups
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags,{Name ="${var.name}-rabbitmq" })
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name = "${var.name}-rabbitmq"

  engine_type                = "RabbitMQ"
  engine_version             = var.engine_version
  storage_type               = var.storage_type
  host_instance_type         = var.instance_type
  deployment_mode            = var.enable_cluster_mode ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = var.publicly_accessible
  subnet_ids                 = var.enable_cluster_mode ? var.subnet_ids : [var.subnet_ids[0]]
  security_groups            = [aws_security_group.rabbitmq.id]
  user {
    console_access = true
    username       = var.username
    password       = random_password.rabbitmq_password.result
  }

  tags = var.tags
}
