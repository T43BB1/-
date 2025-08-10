
variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "The allocated storage for the RDS instance"
}

variable "db_engine" {
  type        = string
  default     = "mysql"
  description = "The database engine"
}

variable "db_engine_version" {
  type        = string
  default     = "8.0"
  description = "The database engine version"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "The instance class for the RDS instance"
}


variable "db_username" {
  type        = string
  default     = "admin"
  description = "The username for the database"
}

variable "db_password" {
  type        = string
  description = "The password for the database"
}

variable "db_parameter_group_name" {
  type        = string
  default     = "default.mysql8.0"
  description = "The parameter group for the database"
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Enable multi-AZ for the RDS instance"
}

variable "db_identifier" {
  type        = string
  description = "The identifier for the RDS instance"
  default     = "my-rds-master"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "mydatabase"
}

variable "private_subnet_a_id" {
  description = "Subnet ID for availability zone A"
  type        = string
}

variable "private_subnet_c_id" {
  description = "Subnet ID for availability zone C"
  type        = string
}
