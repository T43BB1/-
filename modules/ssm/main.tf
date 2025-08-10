# resource "aws_instance" "bastion" {
#   ami           = "ami-040c33c6a51fd5d96" # ubuntu AMI
#   instance_type = var.instance_type
#   subnet_id     = var.subnet_id
#   key_name      = aws_key_pair.bastion.key_name # 키 페어 이름 연결
#   associate_public_ip_address = true

#  # 사용자 데이터 추가
#   user_data = <<-EOF
#     #!/bin/bash
#     sudo apt-get update
#     sudo apt-get install -y openssh-server
#     sudo systemctl enable ssh
#     sudo systemctl start ssh
#   EOF 

#   tags = {
#     Name = "BastionHost"
#   }
# }

# resource "tls_private_key" "bastion_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "aws_key_pair" "bastion" {
#   key_name   = "bastion-key"
#   public_key = tls_private_key.bastion_key.public_key_openssh
# }

# resource "local_file" "bastion_ssh_key" {
#   content  = tls_private_key.bastion_key.private_key_pem
#   filename = "${path.module}/bastion.pem"  # 현재 terraform 모듈 디렉터리 
# }


# # Windows용 null_resource
# resource "null_resource" "set_bastion_key_permission_windows" {
#   provisioner "local-exec" {
#     command = "icacls ${path.module}/bastion.pem /inheritance:r /grant:r everyone:RX"
#   }
#   depends_on = [local_file.bastion_ssh_key]
# }

#--------------- SSM 설정 -----------------------

# IAM 역할 생성
resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM 역할에 SSM 정책 연결
resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# IAM 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# 웹 서버 인스턴스 생성
resource "aws_instance" "web_server" {
  ami           = "ami-040c33c6a51fd5d96" # 원하는 AMI ID
  instance_type = "t2.micro"              # 인스턴스 타입
  subnet_id     = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  # associate_public_ip_address = true
  
  # 사용자 데이터 추가
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  EOF

  tags = {
    Name = "SSm-WebServer"
  }
}

#-------------------------------------------------------------