# EC2 관련 변수
variable "ec2_ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
  default     = "ami-0c1a7f89451184c8b" # 원하는 AMI ID로 변경
}

variable "ec2_instance_type" {
  type        = string
  description = "Instance type for the EC2 instances"
  default     = "t3.micro"
}

variable "ec2_min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
  default     = 2
}

variable "ec2_max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
  default     = 4
}

variable "ec2_desired_capacity" {
  type        = number
  description = "Desired capacity of the Auto Scaling Group"
  default     = 2
}

# RDS 관련 변수
variable "rds_allocated_storage" {
  type        = number
  description = "The allocated storage for the RDS instance"
  default     = 20
}

variable "rds_engine" {
  type        = string
  description = "The database engine"
  default     = "mysql"
}

variable "rds_engine_version" {
  type        = string
  description = "The database engine version"
  default     = "8.0"
}

variable "rds_instance_class" {
  type        = string
  description = "The instance class for the RDS instance"
  default     = "db.t3.micro"
}

variable "rds_identifier" {
  type        = string
  description = "The identifier for the RDS instance"
  default     = "my-rds-master"
}

variable "rds_name" {
  type        = string
  description = "The name of the database"
  default     = "mydatabase"
}

variable "rds_username" {
  type        = string
  description = "The username for the database"
  default     = "admin"
}

variable "rds_password" {
  type        = string
  description = "The password for the database"
}

variable "rds_multi_az" {
  type        = bool
  description = "Enable multi-AZ for the RDS instance"
  default     = false
}


