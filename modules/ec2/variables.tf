variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instances"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
}

variable "min_size" {
  type        = number
  default     = 2
}

variable "max_size" {
  type        = number
  default     = 4
}

variable "desired_capacity" {
  type        = number
  default     = 2
}
