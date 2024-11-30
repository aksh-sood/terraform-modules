data "aws_caller_identity" "current" {}

locals {
  combined_waf_rules = merge(var.default_waf_rules, var.modify_managed_waf_rules)
  name               = var.name
}

resource "aws_wafv2_ip_set" "this" {
  for_each = var.allowed_ip_sets

  name               = "${local.name}-${each.key}"
  description        = "IP set for ${each.key}"
  scope              = "REGIONAL"
  ip_address_version = each.value.ip_address_version
  addresses          = each.value.addresses

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl" "this" {
  name        = local.name
  description = "WAF for ${local.name} environment"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.combined_waf_rules

    content {
      name     = rule.key
      priority = rule.value.priority

      dynamic "action" {
        for_each = lookup(rule.value, "action", null) != null ? [lookup(rule.value, "action")] : []
        content {
          dynamic "allow" {
            for_each = action.value == "allow" ? [1] : []
            content {}
          }
          dynamic "block" {
            for_each = action.value == "block" ? [1] : []
            content {}
          }
          dynamic "count" {
            for_each = action.value == "count" ? [1] : []
            content {}
          }
        }
      }

      dynamic "override_action" {
        for_each = lookup(rule.value, "action", null) == null ? [1] : []
        content {
          dynamic "count" {
            for_each = contains(lookup(rule.value, "rules_to_count", []), rule.key) ? [1] : []
            content {}
          }
          dynamic "none" {
            for_each = !contains(lookup(rule.value, "rules_to_count", []), rule.key) ? [1] : []
            content {}
          }
        }
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = can(rule.value.rules_to_count) ? [1] : []
          content {
            name        = rule.key
            vendor_name = "AWS"

            dynamic "rule_action_override" {
              for_each = rule.value.rules_to_count
              content {
                action_to_use {
                  count {}
                }
                name = rule_action_override.value
              }
            }
          }
        }

        dynamic "ip_set_reference_statement" {
          for_each = can(rule.value.statement.IPSetReferenceStatement) ? [rule.value.statement.IPSetReferenceStatement] : []
          content {
            arn = aws_wafv2_ip_set.this[ip_set_reference_statement.value].arn
          }
        }

        dynamic "rule_group_reference_statement" {
          for_each = can(rule.value.statement.RuleGroupReferenceStatement) ? [rule.value.statement.RuleGroupReferenceStatement] : []
          content {
            arn = rule_group_reference_statement.value.ARN
            dynamic "rule_action_override" {
              for_each = rule_group_reference_statement.value.RuleActionOverrides != null ? rule_group_reference_statement.value.RuleActionOverrides : []
              content {
                action_to_use {
                  dynamic "allow" {
                    for_each = rule_action_override.value.ActionToUse == "ALLOW" ? [1] : []
                    content {}
                  }
                  dynamic "block" {
                    for_each = rule_action_override.value.ActionToUse == "BLOCK" ? [1] : []
                    content {}
                  }
                  dynamic "count" {
                    for_each = rule_action_override.value.ActionToUse == "COUNT" ? [1] : []
                    content {}
                  }
                }
                name = rule_action_override.value.Name
              }
            }
          }
        }

        dynamic "or_statement" {
          for_each = can(rule.value.statement.OrStatement) ? [rule.value.statement.OrStatement] : []
          content {
            dynamic "statement" {
              for_each = or_statement.value.Statements
              content {
                dynamic "byte_match_statement" {
                  for_each = can(statement.value.ByteMatchStatement) ? [statement.value.ByteMatchStatement] : []
                  content {
                    positional_constraint = byte_match_statement.value.PositionalConstraint
                    search_string         = byte_match_statement.value.SearchString
                    field_to_match {
                      dynamic "uri_path" {
                        for_each = can(byte_match_statement.value.FieldToMatch.UriPath) ? [1] : []
                        content {}
                      }
                      dynamic "single_header" {
                        for_each = can(byte_match_statement.value.FieldToMatch.SingleHeader) ? [byte_match_statement.value.FieldToMatch.SingleHeader] : []
                        content {
                          name = single_header.value.Name
                        }
                      }
                    }
                    text_transformation {
                      priority = byte_match_statement.value.TextTransformations[0].Priority
                      type     = byte_match_statement.value.TextTransformations[0].Type
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "rate_based_statement" {
          for_each = can(rule.value.statement.RateBasedStatement) ? [rule.value.statement.RateBasedStatement] : []
          content {
            limit              = rate_based_statement.value.Limit
            aggregate_key_type = rate_based_statement.value.AggregateKeyType
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = try(rule.value.visibility_config.cloudwatch_metrics_enabled, true)
        metric_name                = try(rule.value.visibility_config.metric_name, "${rule.key}-metric")
        sampled_requests_enabled   = try(rule.value.visibility_config.sampled_requests_enabled, true)
      }
    }
  }

  dynamic "rule" {
    for_each = var.custom_waf_rules
    content {
      name     = rule.key
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "or_statement" {
          for_each = can(rule.value.statement.OrStatement) ? [rule.value.statement.OrStatement] : []
          content {
            dynamic "statement" {
              for_each = or_statement.value.Statements
              content {
                dynamic "byte_match_statement" {
                  for_each = can(statement.value.ByteMatchStatement) ? [statement.value.ByteMatchStatement] : []
                  content {
                    positional_constraint = byte_match_statement.value.PositionalConstraint
                    search_string         = byte_match_statement.value.SearchString
                    field_to_match {
                      dynamic "uri_path" {
                        for_each = can(byte_match_statement.value.FieldToMatch.UriPath) ? [1] : []
                        content {}
                      }
                      dynamic "single_header" {
                        for_each = can(byte_match_statement.value.FieldToMatch.SingleHeader) ? [byte_match_statement.value.FieldToMatch.SingleHeader] : []
                        content {
                          name = single_header.value.Name
                        }
                      }
                    }
                    dynamic "text_transformation" {
                      for_each = byte_match_statement.value.TextTransformations
                      content {
                        priority = text_transformation.value.Priority
                        type     = text_transformation.value.Type
                      }
                    }
                  }
                }
              }
            }
          }
        }
        dynamic "byte_match_statement" {
          for_each = can(rule.value.statement.byte_match_statement) ? [rule.value.statement.byte_match_statement] : []
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string
            field_to_match {
              dynamic "uri_path" {
                for_each = can(byte_match_statement.value.field_to_match.uri_path) ? [1] : []
                content {}
              }
              dynamic "single_header" {
                for_each = can(byte_match_statement.value.field_to_match.single_header) ? [byte_match_statement.value.field_to_match.single_header] : []
                content {
                  name = single_header.value.name
                }
              }
            }
            dynamic "text_transformation" {
              for_each = byte_match_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }
        # Add other statement types as needed
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        metric_name                = rule.value.visibility_config.metric_name
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }
    }
  }

  # Rule to block unspecified IPs
  dynamic "rule" {
    for_each = length(var.allowed_ip_sets) > 0 ? [1] : []
    content {
      name     = "BlockUnspecifiedIPs"
      priority = 0

      action {
        block {}
      }

      statement {
        and_statement {
          dynamic "statement" {
            for_each = var.allowed_ip_sets
            content {
              not_statement {
                statement {
                  ip_set_reference_statement {
                    arn = aws_wafv2_ip_set.this[statement.key].arn
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "BlockUnspecifiedIPs"
        sampled_requests_enabled   = true
      }
    }
  }

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name}-waf"
    sampled_requests_enabled   = true
  }

  depends_on = [aws_wafv2_ip_set.this]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl_association" "loadbalancer" {
  for_each = toset(var.loadbalancer_arns)

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_s3_bucket" "waf_logs" {
  bucket = "aws-waf-logs-${local.name}"
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    id     = "delete_old_logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWAFLogging"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.waf_logs.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${aws_s3_bucket.waf_logs.id}"
          }
        }
      }
    ]
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [aws_s3_bucket.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior = "KEEP"

      condition {
        action_condition {
          action = "COUNT"
        }
      }

      condition {
        action_condition {
          action = "BLOCK"
        }
      }

      requirement = "MEETS_ANY"
    }
  }
}
