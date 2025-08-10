variable "name" {
  description = "Name of the WAF"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IP addresses"
  type        = list(string)
}

variable "resource_arn" {
  description = "Resource ARN to associate with WAF"
  type        = string
}
