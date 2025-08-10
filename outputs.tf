# VPC Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

# EC2 Outputs
output "ec2_asg_name" {
  value = module.ec2.asg_name
}

# RDS Outputs
output "db_master_endpoint" {
  value = module.rds.db_master_endpoint
}

output "db_read_replica_endpoint" {
  value = module.rds.db_read_replica_endpoint
}

# ALB Outputs
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "master_db_id" {
  value = module.rds.master_db_id
}



#-----------------bastion-------------------#
output "bastion_id" {
  value = module.bastion.bastion_id
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}
#--------------------------------------------#


# #------------------- WAF -----------------------
# output "waf_acl_arn" {
#   value = module.waf.waf_acl_arn
# }

# # output "allowed_ip_set_arn" {
# #   value = module.waf.allowed_ip_set_arn
# # }
# #-------------------------------------------------------------