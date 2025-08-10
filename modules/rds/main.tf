resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [var.private_subnet_a_id, var.private_subnet_c_id] # 가용 영역 A와 C의 서브넷 포함

  tags = {
    Name = "RDS-Subnet-Group"
  }
}

resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS"
  deletion_window_in_days = 10 # 키 삭제 대기 기간 설정 (7~30일)
  enable_key_rotation     = true # 자동 키 교체 활성화
  tags = {
    Name = "RDS-KMS-Key"
  }
}

# resource "aws_secret_manager_secret" "rds_secret" {
#   name = "rds-secret"
#   description = "RDS Secret"
#   kms_key_id = aws_kms_key.rds_kms_key.arn # KMS 키 ID 설정
#   secret_string = jsonencode({
#     username = "test_user"
#     password = "test_password"
#   })
# }

resource "aws_db_instance" "db_master" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.34"
  instance_class         = "db.t3.micro"
  identifier             = "rds-6zo-master"
  db_name                = "collabtool"
  username               = "test_user"
  # password             = ""
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name # 서브넷 그룹 통합 사용
  multi_az               = false
  backup_retention_period = 7
  availability_zone      = "ap-northeast-2a"
  publicly_accessible    = false
  storage_encrypted      = true
  kms_key_id = aws_kms_key.rds_kms_key.arn # KMS 키 ID 설정
  skip_final_snapshot    = true

  tags = {
    Name = "RDS-Master"
  }
}
# Read Replica 설정
resource "aws_db_instance" "db_read_replica" {
  replicate_source_db    = aws_db_instance.db_master.identifier
  instance_class         = "db.t3.micro"
 # db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name # 서브넷 그룹 통합 사용
  availability_zone      = "ap-northeast-2c"
  publicly_accessible    = false
  skip_final_snapshot = true # 최종 스냅샷 생성 생략
  # storage_encrypted     = true  # StorageEncrypted 활성화

  tags = {
    Name = "RDS-ReadReplica"
  }
}

