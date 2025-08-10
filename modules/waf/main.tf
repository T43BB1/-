resource "aws_wafv2_ip_set" "allowed_ips" {
  name               = "${var.name}-allowed-ips"
  scope              = "REGIONAL" # WAF 범위 (ALB와 같은 지역 자원에 사용)
  ip_address_version = "IPV4"     # IPv4 사용

  addresses = var.allowed_ips # 허용할 IP 주소를 변수로 입력
}

resource "aws_wafv2_web_acl" "main_waf_acl" {
  name        = var.name   # WAF 이름
  scope       = "REGIONAL" # ALB와 같은 리소스에 사용

  default_action {
    allow {} # 기본적으로 모든 트래픽 허용
  }

  # 허용 IP 규칙
  rule {
    name     = "AllowSpecificIPs"
    priority = 1 # 우선순위 1
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowed_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowSpecificIPs"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection 차단
  rule {
    name     = "SQLInjectionProtection"
    priority = 2
    action {
      block {}
    }
    statement {
      sqli_match_statement {
        field_to_match {
          body {} # HTTP 요청의 Body 확인
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionProtection"
      sampled_requests_enabled   = true
    }
  }

  # XSS(Cross-Site Scripting) 차단
  rule {
    name     = "CrossSiteScriptingProtection"
    priority = 3
    action {
      block {}
    }
    statement {
      xss_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CrossSiteScriptingProtection"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }
}

#WAF를 ALB에 연결
 resource "aws_wafv2_web_acl_association" "assoc" {
  resource_arn = var.resource_arn # ALB ARN
  web_acl_arn  = aws_wafv2_web_acl.main_waf_acl.arn
}


