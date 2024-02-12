resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = var.environment
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis_sg" {
  name        = "Redis-${var.environment}-${var.region}"
  description = "Redis Security group for ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "K8s nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.whitelist_security_groups
  }

  egress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.whitelist_security_groups
  }

  tags = merge(
    var.tags,
    {
      Name = "Redis-${var.environment}"
    },
  )
}

resource "aws_elasticache_cluster" "redis" {

  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  
  num_cache_nodes      = 1
  port                 = 6379
  engine               = "redis"
  cluster_id           = var.environment
  node_type            = var.redis_node_type
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.example.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.example.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags                 = var.tags
}