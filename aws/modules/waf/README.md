# WAF (Web Application Firewall) Module Documentation
This Terraform module creates and configures an AWS WAF (Web Application Firewall) with customizable rules and settings. It provides a flexible way to set up protection for your web applications against common web exploits.

## Features

- Creation of AWS WAFv2 Web ACL with configurable rules
- Support for AWS Managed Rule Sets
- Custom rule creation
- IP set creation and management
- Association with Application Load Balancer
- WAF logging to S3 bucket
- Flexible configuration options

## Usage

```hcl
module "waf" {
  source = "path/to/waf/module"

  customer    = "example"
  environment = "prod"

  tags = {
    Project     = "ExampleProject"
    Environment = "Production"
  }

  loadbalancer_arn = aws_lb.example.arn

  allowed_ip_sets = {
    "allowed_ips" = {
      ip_address_version = "IPV4"
      addresses          = ["192.0.2.0/24", "198.51.100.0/24"]
    }
  }

  custom_waf_rules = {
    "block_specific_uri" = {
      priority = 1
      action   = "block"
      statement = {
        byte_match_statement = {
          positional_constraint = "STARTS_WITH"
          search_string         = "/admin"
          field_to_match = {
            uri_path = {}
          }
          text_transformation = [
            {
              priority = 1
              type     = "LOWERCASE"
            }
          ]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "block-admin-uri"
        sampled_requests_enabled   = true
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| default_waf_rules | Default AWS Managed Rule Sets | `map(object)` | See below | no |
| modify_managed_waf_rules | Map to modify or override default WAF rules | `map(object)` | `{}` | no |
| custom_waf_rules | Custom WAF rules to be added to the WAF | `map(object)` | `{}` | no |
| allowed_ip_sets | IP sets to be created and used in WAF rules | `map(object)` | `{}` | no |
| loadbalancer_arns | List of load balancer ARNs to associate with WAF | `list(string)` | `[]` | no |
| name | Name for WAF | `string` | - | yes |
| environment | Environment name for resource naming | `string` | - | yes |

### Default WAF Rules

The module comes with a set of default AWS Managed Rule Sets. Here's a summary:

```hcl
default = {
  "AWSManagedRulesKnownBadInputsRuleSet" = {
    rules_to_count = ["SizeRestrictions_QUERYSTRING", "NoUserAgent_HEADER"]
    priority       = 20
  },
  "AWSManagedRulesAdminProtectionRuleSet" = {
    rules_to_count = ["AdminProtection_URIPATH"]
    priority       = 40
  },
  "AWSManagedRulesAmazonIpReputationList" = {
    rules_to_count = []
    priority       = 60
  },
  "AWSManagedRulesAnonymousIpList" = {
    rules_to_count = []
    priority       = 80
  },
  "AWSManagedRulesCommonRuleSet" = {
    rules_to_count = ["CrossSiteScripting_BODY", "CrossSiteScripting_QUERYARGUMENTS", "CrossSiteScripting_COOKIE", "CrossSiteScripting_URIPATH", "SizeRestrictions_BODY"]
    priority       = 100
  },
  "AWSManagedRulesLinuxRuleSet" = {
    rules_to_count = []
    priority       = 120
  },
  "AWSManagedRulesSQLiRuleSet" = {
    rules_to_count = ["SQLi_BODY"]
    priority       = 140
  }
}
```

These rules can be modified or overridden using the `modify_managed_waf_rules` variable.

## Outputs

| Name | Description |
|------|-------------|
| waf_arn | ARN of the WAF |

This module outputs the ARN of the created WAF, which can be used for further configuration or integration with other resources.

## Resources Created

1. AWS WAFv2 Web ACL
2. AWS WAFv2 IP Sets (if specified)
3. S3 Bucket for WAF logs
4. WAF to ALB association (if loadbalancer_arn is provided)

## Notes

- The module creates a default "allow" action for the Web ACL. Any traffic not matched by the rules will be allowed.
- If `allowed_ip_sets` are specified, a rule to block all unspecified IPs is automatically created with the highest priority (0).
- WAF logs are stored in an S3 bucket with a lifecycle policy to delete logs after 90 days.
- The module uses `create_before_destroy` lifecycle rule for the Web ACL and IP Sets to minimize downtime during updates.

## Customization

You can customize the WAF configuration by modifying the following variables:

- `modify_managed_waf_rules`: Override or modify the default AWS Managed Rule Sets.
- `custom_waf_rules`: Add your own custom rules to the WAF.
- `allowed_ip_sets`: Create IP sets and automatically generate rules to allow traffic only from these IP ranges.

Example of custom rule:

```hcl
custom_waf_rules = {
  "rate_limit_rule" = {
    priority = 5
    action   = "block"
    statement = {
      rate_based_statement = {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    visibility_config = {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-rule"
      sampled_requests_enabled   = true
    }
  }
}
```

This custom rule creates a rate-based rule that blocks IP addresses that make more than 2000 requests in 5 minutes.

Remember to adjust the rules and configurations based on your specific security requirements and the nature of your web application.
