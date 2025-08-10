#!/bin/bash
sudo apt update -y
sudo apt install -y apache2 php libapache2-mod-php curl unzip
sudo systemctl enable apache2
sudo systemctl start apache2
echo "<h1>Welcome to Apache Web Server</h1>" > /var/www/html/index.html
sudo systemctl start apache2




# # S3 버킷에서 PHP 파일 다운로드
# cd /var/www/html/
# curl -O https://your-s3-bucket-url/index.php
# curl -O https://your-s3-bucket-url/login.php
# curl -O https://your-s3-bucket-url/project.php
# curl -O https://your-s3-bucket-url/project_detail.php

# # 권한 설정
# sudo chown -R www-data:www-data /var/www/html/
# sudo chmod -R 755 /var/www/html/

# # 기본 PHP 정보 페이지 생성 (테스트 용도)
# echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
