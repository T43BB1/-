#----------------cloudtrail-------------------------
variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch log group for CloudTrail"
  type        = string
  default     = "cloudtrail-log-group" # 기본 로그 그룹 이름
}



#--------------------cloudwatch----------------------
variable "name" {
  description = "Name of CloudTrail Log Group"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}


variable "retention_in_days" {
  description = "Number of days to retain logs"
  default     = 90
}

variable "s3_bucket_name" {
  description = "S3 bucket for CloudTrail logs"
  type        = string
}
#---------------------------------------------------

variable "enable_guardduty" {
  description = "Enable GuardDuty integration"
  type        = bool
  default     = false
}

#--------------vpc_flow_logs에 필요함-------------
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where VPC Flow Logs will be enabled"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}
