variable "subnet_id" {
  description = "Subnet ID where the Bastion Host will be deployed"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Bastion Host"
  type        = string
  default     = "t3.micro"
}

variable "name" {
  description = "Name tag for the Bastion Host"
  type        = string
  default     = "BastionHost"
}

variable "public_key" {
  type = string
}


