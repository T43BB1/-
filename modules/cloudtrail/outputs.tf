#----------------cloudtrail----------------
output "cloudtrail_id" {
  value = aws_cloudtrail.main.id
}

output "s3_bucket_id" {
  value = aws_s3_bucket.cloudtrail_bucket.id
}

#--------------cloudwatch--------------------
output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.cloudtrail_logs.arn
}

#-------------------guardduty----------------------
output "guardduty_detector_id" {
  value = aws_guardduty_detector.main.id
}
