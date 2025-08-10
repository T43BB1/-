resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}



resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index%2]

  tags = {
    Name = "PrivateSubnet-${count.index + 1}"
  }
}

# Web 서버 보안 그룹
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP, HTTPS, and SSH from Bastion Host"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH from Bastion Host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}


# ALB 보안 그룹
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow inbound traffic to ALB"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH  from Bastion Host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "Allow HTTPS from Bastion Host"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Internet Gateway 추가
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainIGW"
  }
}

# Public Subnet에 Route Table 추가
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Public Subnet에 Route Table 연결
resource "aws_route_table_association" "public_rt_assoc" {
  count     = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}




#################
# Elastic IP 생성
# Elastic IP for NAT Gateway in AZ-A
resource "aws_eip" "nat_gateway_eip_a" {
  domain = "vpc"
  tags = {
    Name = "NAT-Gateway-EIP-A"
  }
}

# Elastic IP for NAT Gateway in AZ-C
resource "aws_eip" "nat_gateway_eip_c" {
  domain = "vpc"
  tags = {
    Name = "NAT-Gateway-EIP-C"
  }
}


# NAT Gateway 생성
# NAT Gateway for AZ-A
resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_eip.nat_gateway_eip_a.id
  
  subnet_id     = aws_subnet.public[0].id # AZ-A 퍼블릭 서브넷
  tags = {
    Name = "NAT-Gateway-A"
  }
}

# NAT Gateway for AZ-C
resource "aws_nat_gateway" "nat_gateway_c" {
  allocation_id = aws_eip.nat_gateway_eip_c.id
  subnet_id     = aws_subnet.public[1].id # AZ-C 퍼블릭 서브넷
  tags = {
    Name = "NAT-Gateway-C"
  }
}


# Private Subnet용 Route Table 생성
# Route Table for Private Subnet in AZ-A
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
  }

  tags = {
    Name = "PrivateRouteTable-A"
  }
}

# Route Table for Private Subnet in AZ-C
resource "aws_route_table" "private_rt_c" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_c.id
  }

  tags = {
    Name = "PrivateRouteTable-C"
  }
}


# Private Subnet에 Route Table 연결
# Route table associations for PrivateSubnet-1 and PrivateSubnet-3 to PrivateRouteTable-A
resource "aws_route_table_association" "private_rt_assoc_a_1" {
  subnet_id      = aws_subnet.private[0].id  # PrivateSubnet-1
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_rt_assoc_a_3" {
  subnet_id      = aws_subnet.private[2].id  # PrivateSubnet-3
  route_table_id = aws_route_table.private_rt_a.id
}

# Route table associations for PrivateSubnet-2 and PrivateSubnet-4 to PrivateRouteTable-C
resource "aws_route_table_association" "private_rt_assoc_c_2" {
  subnet_id      = aws_subnet.private[1].id  # PrivateSubnet-2
  route_table_id = aws_route_table.private_rt_c.id
}

resource "aws_route_table_association" "private_rt_assoc_c_4" {
  subnet_id      = aws_subnet.private[3].id  # PrivateSubnet-4
  route_table_id = aws_route_table.private_rt_c.id
}


resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH traffic for Bastion host"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 테스트용. 실제 사용 시 본인 IP만 허용.
  }

  #   ingress {
  #   description = "Allow SSH from Admin"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["YOUR_ADMIN_IP/32"] # 관리자 IP
  # }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionSecurityGroup"
  }
}
