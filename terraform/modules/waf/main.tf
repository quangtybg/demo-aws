resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  visibility_config {
    sampled_requests_enabled     = true
    cloudwatch_metrics_enabled   = true
    metric_name                  = var.name
  }

  rule {
    name     = "AWSManagedCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "aws_managed"
    }
  }
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = var.alb_arn
  web_acl_arn   = aws_wafv2_web_acl.this.arn
}

output "waf_arn" { value = aws_wafv2_web_acl.this.arn }
