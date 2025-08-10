# output "bastion_id" {
#   description = "ID of the Bastion Host instance"
#   value       = aws_instance.bastion.id
# }

# output "bastion_public_ip" {
#   description = "Public IP address of the Bastion Host"
#   value       = aws_instance.bastion.public_ip
# }

# output "bastion_ssh_key_path" {
#   value = local_file.bastion_ssh_key.filename
# }

output "web_server_instance_id" {
  description = "The ID of the web server instance"
  value       = aws_instance.web_server.id
}

output "ssm_role_name" {
  description = "The name of the SSM role"
  value       = aws_iam_role.ssm_role.name
}