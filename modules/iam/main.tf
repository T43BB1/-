
#--------- SecTeam IAM Group ---------#
resource "aws_iam_group" "SecTeam" {
  name = "SecTeam"
}

resource "aws_iam_policy" "SecurityPolicyAdmin" {
  name        = "SecurityPolicyAdmin"
  description = "Policy for IAM User/Policy management, Role definition, GuardDuty, Inspector, RDS security group, and KMS key management"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:*User",
          "iam:*Policy",
          "iam:*Role",
          "guardduty:*",
          "inspector:*",
          "rds:DescribeDBSecurityGroups",
          "rds:ModifyDBSecurityGroup",
          "kms:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "SecurityOperationsAdmin" {
  name        = "SecurityOperationsAdmin"
  description = "Policy for managing network security groups, ACLs, and VPC subnet settings"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeNetworkAcls",
          "ec2:CreateNetworkAcl",
          "ec2:DeleteNetworkAcl",
          "ec2:ReplaceNetworkAclAssociation",
          "ec2:ReplaceNetworkAclEntry",
          "ec2:DescribeSubnets",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "SecurityAuditor" {
  name        = "SecurityAuditor"
  description = "Policy for readonly access to CloudTrail/CloudWatch Logs, IAM resource access review, and GuardDuty findings analysis"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudtrail:LookupEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:GetServiceLastAccessedDetails",
          "guardduty:GetFindings",
          "guardduty:ListFindings",
          "guardduty:DescribeDetector"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_SecurityPolicyAdmin" {
  group      = aws_iam_group.SecTeam.name
  policy_arn = aws_iam_policy.SecurityPolicyAdmin.arn
}

resource "aws_iam_group_policy_attachment" "attach_SecurityOperationsAdmin" {
  group      = aws_iam_group.SecTeam.name
  policy_arn = aws_iam_policy.SecurityOperationsAdmin.arn
}

resource "aws_iam_group_policy_attachment" "attach_SecurityAuditor" {
  group      = aws_iam_group.SecTeam.name
  policy_arn = aws_iam_policy.SecurityAuditor.arn
}
#-------------------------------------------------------------

#--------- SecTeam IAM User ---------#
resource "aws_iam_user" "SecTeamUser" {
  name = "SecTeamUser"
  path = "/system/"
}

resource "aws_iam_user_group_membership" "SecTeamMembership" {
  user    = aws_iam_user.SecTeamUser.name
  groups  = [aws_iam_group.SecTeam.name]
}
#------------------------------------#


#--------- DevTeam IAM Group ---------#
resource "aws_iam_group" "DevTeam" {
  name = "DevTeam"
}

resource "aws_iam_policy" "appDev" {
  name        = "appDev"
  description = "Policy for creating and stopping EC2 instances in privatesubnet[0], managing ELB, and creating and managing Auto Scaling policies"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:Placement": "privatesubnet[0]"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:ModifyLoadBalancerAttributes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:PutScalingPolicy",
          "autoscaling:DeletePolicy"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "dbAdmin" {
  name        = "dbAdmin"
  description = "Policy for creating and managing RDS instances in privatesubnet[1], and managing DB backups and restores"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "rds:DBSubnetGroup": "privatesubnet[1]"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "rds:CreateDBSnapshot",
          "rds:DeleteDBSnapshot",
          "rds:DescribeDBSnapshots",
          "rds:RestoreDBInstanceFromDBSnapshot"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "logMonitoring" {
  name        = "logMonitoring"
  description = "Policy for readonly access to CloudTrail/CloudWatch logs"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudtrail:LookupEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "ssm_access" {
  name        = "SSMAccess"
  description = "Policy to allow SSM access to EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:DescribeInstanceInformation",
          "ssm:GetCommandInvocation",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:SendCommand",
          "ssm:StartSession",
          "ssm:TerminateSession"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_appDev" {
  group      = aws_iam_group.DevTeam.name
  policy_arn = aws_iam_policy.appDev.arn
}

resource "aws_iam_group_policy_attachment" "attach_dbAdmin" {
  group      = aws_iam_group.DevTeam.name
  policy_arn = aws_iam_policy.dbAdmin.arn
}

resource "aws_iam_group_policy_attachment" "attach_logMonitoring" {
  group      = aws_iam_group.DevTeam.name
  policy_arn = aws_iam_policy.logMonitoring.arn
}

resource "aws_iam_group_policy_attachment" "attach_ssm_access" {
  group      = aws_iam_group.DevTeam.name
  policy_arn = aws_iam_policy.ssm_access.arn
}
#-------------------------------------------------------------


#--------- DevTeam IAM User ---------#
resource "aws_iam_user" "DevTeamUser" {
  name = "DevTeamUser"
  path = "/system/"
}

resource "aws_iam_group_membership" "DevTeam_membership" {
  name  = "DevTeamMembership"
  users = [aws_iam_user.DevTeamUser.name]
  group = aws_iam_group.DevTeam.name
}
#--------- DevTeam IAM User ---------#



#--------- OperTeam IAM Group ---------#
resource "aws_iam_group" "OperTeam" {
  name = "OperTeam"
}

resource "aws_iam_policy" "InfraOperationsAdmin" {
  name        = "InfraOperationsAdmin"
  description = "Policy for checking, starting, and stopping EC2 instances, managing network settings (VPC, Subnet), and managing Auto Scaling and ELB states"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:ModifyVpcAttribute",
          "ec2:ModifySubnetAttribute"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:ModifyLoadBalancerAttributes"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateNetworkAcl",
          "ec2:DeleteNetworkAcl",
          "ec2:ReplaceNetworkAclAssociation",
          "ec2:ReplaceNetworkAclEntry"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "SysMonitor" {
  name        = "SysMonitor"
  description = "Policy for creating and managing CloudWatch Alarms, read-only access to CloudTrail logs, and checking EC2 status and system logs"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudtrail:LookupEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstanceStatus",
          "ec2:GetConsoleOutput"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "iam:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateNetworkAcl",
          "ec2:DeleteNetworkAcl",
          "ec2:ReplaceNetworkAclAssociation",
          "ec2:ReplaceNetworkAclEntry"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_InfraOperationsAdmin" {
  group      = aws_iam_group.OperTeam.name
  policy_arn = aws_iam_policy.InfraOperationsAdmin.arn
}

resource "aws_iam_group_policy_attachment" "attach_SysMonitor" {
  group      = aws_iam_group.OperTeam.name
  policy_arn = aws_iam_policy.SysMonitor.arn
}
#-------------------------------------------------------------



#--------- OperTeam IAM User ---------#
resource "aws_iam_user" "OperTeamUser" {
  name = "OperTeamUser"
  path = "/system/"
}

resource "aws_iam_group_membership" "OperTeam_membership" {
  name  = "OperTeamMembership"
  users = [aws_iam_user.OperTeamUser.name]
  group = aws_iam_group.OperTeam.name
}
#--------- OperTeam IAM User ---------#



#-------- BusinessTeam IAM Group --------#
resource "aws_iam_group" "BusinessTeam" {
  name = "BusinessTeam"
}

resource "aws_iam_policy" "BillingAdmin" {
  name        = "BillingAdmin"
  description = "Policy for full access to Billing console, using AWS Cost Explorer, and creating and managing budgets"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "aws-portal:ViewBilling",
          "aws-portal:ModifyBilling",
          "ce:*",
          "budgets:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "ec2:*",
          "rds:*",
          "s3:*",
          "iam:*",
          "lambda:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "guardduty:*",
          "inspector:*",
          "cloudwatch:*",
          "cloudtrail:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "CostAnalyst" {
  name        = "CostAnalyst"
  description = "Policy for read-only access to cost-related logs in CloudWatch/CloudTrail, reading CostExplorer data, and reviewing AWS Usage Reports"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "cloudtrail:LookupEvents",
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetReservationUtilization",
          "ce:GetRightsizingRecommendation",
          "ce:GetSavingsPlansCoverage",
          "ce:GetSavingsPlansUtilization",
          "ce:GetDimensionValues",
          "ce:GetTags",
          "aws-portal:ViewUsage"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "ec2:*",
          "rds:*",
          "s3:*",
          "iam:*",
          "lambda:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "guardduty:*",
          "inspector:*",
          "cloudwatch:*",
          "cloudtrail:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_BillingAdmin" {
  group      = aws_iam_group.BusinessTeam.name
  policy_arn = aws_iam_policy.BillingAdmin.arn
}

resource "aws_iam_group_policy_attachment" "attach_CostAnalyst" {
  group      = aws_iam_group.BusinessTeam.name
  policy_arn = aws_iam_policy.CostAnalyst.arn
}
#-------------------------------------------------------------

#--------- BusinessTeam IAM User ---------#
resource "aws_iam_user" "BusinessTeamUser" {
  name = "BusinessTeamUser"
  path = "/system/"
}

resource "aws_iam_group_membership" "BusinessTeam_membership" {
  name  = "BusinessTeamMembership"
  users = [aws_iam_user.BusinessTeamUser.name]
  group = aws_iam_group.BusinessTeam.name
}
#--------- BusinessTeam IAM User ---------#