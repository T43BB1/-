output "waf_acl_arn" {
  value = aws_wafv2_web_acl.main_waf_acl.arn
}

output "allowed_ip_set_arn" {
  value = aws_wafv2_ip_set.allowed_ips.arn
}

