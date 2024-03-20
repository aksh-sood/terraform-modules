#Generating a random password gor ActiveMQ
resource "random_password" "activemq_password" {
  length           = 16
  special          = true
  override_special = "!#$&*-_+"
  min_special      = 1
  lower            = true
  min_lower        = 1
  numeric          = true
  min_numeric      = 1
  upper            = true
  min_upper        = 1
}


# Creating a new Security group for Activemq 
resource "aws_security_group" "activemq_sg" {
  name        = "Activemq-${var.name}-${var.region}"
  description = "Activemq Security group for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = ""
    from_port       = 61617
    to_port         = 61617
    protocol        = "tcp"
    security_groups = var.whitelist_security_groups
  }
  ingress {
    description     = ""
    from_port       = 8162
    to_port         = 8162
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

  # Adding name tag for Security group so that we can easily identify it
  tags = var.tags
}

resource "aws_mq_configuration" "mq_configuration" {
  description    = "ActiveMQ provisioning"
  name           = var.name
  engine_type    = "ActiveMQ"
  engine_version = var.engine_version
  data           = file("${path.module}/configuration/activemq_config.xml")
}

resource "aws_mq_broker" "activemq" {
  broker_name = var.name
  configuration {
    id = aws_mq_configuration.mq_configuration.id

  }
  engine_type                = "ActiveMQ"
  engine_version             = var.engine_version
  storage_type               = var.storage_type
  host_instance_type         = var.instance_type
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = var.publicly_accessible
  subnet_ids                 = [var.subnet_ids[0]]
  security_groups            = [aws_security_group.activemq_sg.id]
  tags                       = var.tags
  user {
    console_access = true
    username       = var.username
    password       = random_password.activemq_password.result
  }

}
