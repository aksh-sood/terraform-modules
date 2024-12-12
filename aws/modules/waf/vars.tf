variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "default_waf_rules" {
  type = map(object({
    rules_to_count = list(string)
    priority       = number
  }))

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
      rules_to_count = ["SQLi_BODY", "SQLi_COOKIE"]
      priority       = 140
    }
  }
}

variable "modify_managed_waf_rules" {
  type = map(object({
    rules_to_count = list(string)
    priority       = number
  }))
  default     = {}
  description = "Map to modify or override default WAF rules"
}

variable "custom_waf_rules" {
  type = map(object({
    priority  = number
    action    = string
    statement = any
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name                = string
      sampled_requests_enabled   = bool
    })
  }))
  description = "Custom WAF rules to be added to the WAF"
  default     = {}
}

variable "allowed_ip_sets" {
  type = map(object({
    ip_address_version = string
    addresses          = list(string)
  }))
  description = "IP sets to be created and used in WAF rules"
  default     = {}
}

variable "loadbalancer_arns" {
  description = "List of load balancer ARNs to associate with WAF"
  type        = list(string)
  default     = []
}

variable "name" {
  type        = string
  description = "Name for WAF Web ACL"
}
