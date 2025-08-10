resource "aws_instance" "bastion" {
  ami           = "ami-040c33c6a51fd5d96" # ubuntu AMI
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.bastion.key_name # 키 페어 이름 연결
  associate_public_ip_address = true

  # 사용자 데이터 추가
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh

  EOF

  tags = {
    Name = "BastionHost"
  }
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "local_file" "bastion_ssh_key" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = "${path.module}/bastion.pem"  # 현재 terraform 모듈 디렉터리 
}


# Windows용 null_resource
resource "null_resource" "set_bastion_key_permission_windows" {
  provisioner "local-exec" {
    command = "icacls ${path.module}/bastion.pem /inheritance:r /grant:r everyone:RX"
  }
  depends_on = [local_file.bastion_ssh_key]
}

