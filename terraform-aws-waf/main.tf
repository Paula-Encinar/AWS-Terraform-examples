resource "aws_wafv2_web_acl" "wafacl" {
  name        = "wafwebacl-rules-${var.long_environment}"
  description = "Custom WAFWebACL"
  scope = "GLOBAL"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFWebACL-metric"
    sampled_requests_enabled   = true
  }

  # rule {
  #   name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
  #   priority = 10

  #   override_action {
  #     none {}
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesKnownBadInputsRuleSet"
  #       vendor_name = "AWS"
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "WAFWebACL-metric"
  #     sampled_requests_enabled   = true
  #   }
  # }
  # rule {
  #   name     = "aws-AWSManagedRulesCommonRuleSet"
  #   priority = 0
  #   override_action {
  #     none {}
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       vendor_name = "AWS"
  #       name        = "AWSManagedRulesCommonRuleSet"
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "MetricForAMRCRS"
  #     sampled_requests_enabled   = true
  #   }
  # }
  rule {
    name     = "aws-AWSManagedRulesAmazonIpReputationList"
    priority = 1
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MetricForAMRAIRL"
      sampled_requests_enabled   = true
    }
  }
}
