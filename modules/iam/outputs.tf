output "sec_team_group" {
  description = "IAM Group for SecTeam"
  value       = aws_iam_group.SecTeam.name
}

output "sec_team_user" {
  description = "IAM User for SecTeam"
  value       = aws_iam_user.SecTeamUser.name
}

output "dev_team_group" {
  description = "IAM Group for DevTeam"
  value       = aws_iam_group.DevTeam.name
}

output "dev_team_user" {
  description = "IAM User for DevTeam"
  value       = aws_iam_user.DevTeamUser.name
}

output "oper_team_group" {
  description = "IAM Group for OperTeam"
  value       = aws_iam_group.OperTeam.name
}

output "oper_team_user" {
  description = "IAM User for OperTeam"
  value       = aws_iam_user.OperTeamUser.name
}

output "business_team_group" {
  description = "IAM Group for BusinessTeam"
  value       = aws_iam_group.BusinessTeam.name
}

output "business_team_user" {
  description = "IAM User for BusinessTeam"
  value       = aws_iam_user.BusinessTeamUser.name
}