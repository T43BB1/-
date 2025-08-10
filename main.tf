
provider "aws" {
  region = "ap-northeast-2" 
  profile = "terraform-user"
}

# VPC 모듈 호출
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24" , "10.0.5.0/24", "10.0.6.0/24"]
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
}


# RDS 모듈 호출
module "rds" {
  source                = "./modules/rds"
  private_subnet_a_id   = module.vpc.private_subnets[0] 
  private_subnet_c_id   = module.vpc.private_subnets[1] 
  db_allocated_storage  = 20
  db_engine             = "mysql"
  db_engine_version     = "8.0.34"
  db_instance_class     = "db.t3.micro"
  db_identifier         = "rds-6zo-master"
  db_name               = "collabtool"
  db_username           = "test_user"
  db_password           = "test_password"
  multi_az              = false
}


# EC2 모듈 호출
module "ec2" {
  source             = "./modules/ec2"
  private_subnets    = module.vpc.private_subnets
  security_group_ids = [module.vpc.web_sg] 
  ami_id             = "ami-03d31e4041396b53c"
  instance_type      = "t2.micro"
  min_size           = 2
  max_size           = 4
  desired_capacity   = 2
}

# ALB 모듈 호출
module "alb" {
  source                 = "./modules/alb"
  public_subnets         = module.vpc.public_subnets
  private_subnets        = module.vpc.private_subnets
  security_group_ids     = [module.vpc.alb_sg]
  web_security_group_ids = [module.vpc.web_sg]
  vpc_id                 = module.vpc.vpc_id
}

#--------------- CloudTrail 모듈 호출-----------------------
module "cloudtrail" {
  source            = "./modules/cloudtrail"
  name              = "my-cloudtrail"              # CloudTrail 이름
  s3_bucket_name    = module.cloudtrail.s3_bucket_id # CloudTrail S3 버킷
  log_group_name    = "cloudtrail-log-group"       # CloudWatch Log Group 이름
  account_id        = "061051214607"               # AWS Account ID (루트 변수 전달)
  vpc_id = module.vpc.vpc_id # vpc 모듈의 출력값 전달
  enable_guardduty  = true       # GuardDuty 활성화 여부
  vpc_cidr        = "10.0.0.0/16"
}
#-------------------------------------------------------------


#--------------- bastion -----------------------

# SSH 키 생성
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
module "bastion" {
  source     = "./modules/bastion"
  subnet_id  = module.vpc.public_subnets[0] # AZ 1의 Public Subnet
  instance_type = "t3.micro"
  name       = "BastionHost-AZ1"
  public_key   = tls_private_key.bastion_key.public_key_openssh
}
#-------------------------------------------------------------


#--------------- Route53 -----------------------
/*
module "route53" {
  source      = "./modules/route53"
  zone_id     = "Z009087628PLAUIS0I0F7"
  record_name = "www.hoosyung.click"
  lb_dns_name = module.alb.alb_dns_name   # 수정된 호출
  lb_zone_id  = module.alb.alb_zone_id   # 수정된 호출
}
*/
#-------------------------------------------------------------


#------------------- WAF -----------------------
module "waf" {
  source       = "./modules/waf"
  name         = "waf"
  allowed_ips  = ["203.0.113.0/24", "198.51.100.0/24", "0.0.0.0/24"]
  resource_arn = module.alb.web_alb_arn # ALB ARN
}
#-------------------------------------------------------------


