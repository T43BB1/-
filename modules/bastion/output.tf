output "bastion_id" {
  description = "ID of the Bastion Host instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_ssh_key_path" {
  value = local_file.bastion_ssh_key.filename
}

