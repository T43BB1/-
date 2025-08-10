output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "web_sg" {
  value = aws_security_group.web_sg.id
}

output "alb_sg" {
  value = aws_security_group.alb_sg.id
}


###
# NAT Gateway IDs
output "nat_gateway_a_id" {
  description = "ID of the NAT Gateway in AZ-A"
  value       = aws_nat_gateway.nat_gateway_a.id
}

output "nat_gateway_c_id" {
  description = "ID of the NAT Gateway in AZ-C"
  value       = aws_nat_gateway.nat_gateway_c.id
}

# Elastic IPs for NAT Gateways
output "nat_gateway_eip_a" {
  description = "Elastic IP of NAT Gateway in AZ-A"
  value       = aws_eip.nat_gateway_eip_a.public_ip
}

output "nat_gateway_eip_c" {
  description = "Elastic IP of NAT Gateway in AZ-C"
  value       = aws_eip.nat_gateway_eip_c.public_ip
}




