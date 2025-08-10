output "db_master_endpoint" {
  value = aws_db_instance.db_master.endpoint
}

output "db_read_replica_endpoint" {
  value = aws_db_instance.db_read_replica.endpoint
}

output "master_db_id" {
  value = aws_db_instance.db_master.id
  description = "The ID of the master RDS DB instance"
}