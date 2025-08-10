resource "aws_launch_template" "web_server_lt" {
  name = "web-server-launch-template"

  image_id      = "ami-040c33c6a51fd5d96" # 원하는 AMI ID
  instance_type = "t2.micro"              # 인스턴스 타입
  key_name = "Web-Key"


# ---------- 아파치 설치 ---------- #
user_data = filebase64("user_data.sh")

# S3 버킷에서 PHP 파일 다운로드
#cd /var/www/html/
#curl -O https://your-s3-bucket-url/index.php
#curl -O https://your-s3-bucket-url/login.php
#curl -O https://your-s3-bucket-url/project.php
#curl -O https://your-s3-bucket-url/project_detail.php

# 권한 설정
#sudo chown -R www-data:www-data /var/www/html/
#sudo chmod -R 755 /var/www/html/

# 기본 PHP 정보 페이지 생성 (테스트 용도)
#echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# ---------- 아파치 설치 ---------- #


  network_interfaces {
    security_groups = var.security_group_ids # EC2 보안 그룹
    subnet_id       = element(var.private_subnets, 0) # 첫 번째 서브넷
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "WebServer"
    }
  }
}
# Auto Scaling Group 생성
resource "aws_autoscaling_group" "web_server_asg" {
  launch_template {
    id      = aws_launch_template.web_server_lt.id
    version = "$Latest"
  }

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  vpc_zone_identifier = var.private_subnets

  tag  {
      key                 = "Name"
      value               = "WebServerASG"
      propagate_at_launch = true
    }
  
}


