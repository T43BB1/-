variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnets" {
  type = list(string)
  description = "Private subnets for backend instances"
}


variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
}

variable "web_security_group_ids" {
  type = list(string)
  description = "Security groups for Web servers"
}

variable "vpc_id" {
  type = string
  description = "VPC ID for ALB"

  
}
