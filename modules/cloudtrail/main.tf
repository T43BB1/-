/*
CloudTrail:
  AWS 리소스에서 수행된 모든 API 호출 기록.
    예: EC2 인스턴스의 비정상 종료 시도.
GuardDuty:
  CloudTrail 로그를 분석하여 악의적인 활동 탐지.
  탐지 사례:
    불법적인 IP에서 API 호출 발생.
    허가되지 않은 IAM 사용자 활동.
CloudWatch Logs:
  CloudTrail 로그를 CloudWatch에서 실시간으로 분석.
  사용자 정의 경보:
    예: 특정 API 호출("TerminateInstances")이 발생할 때 경고
*/


resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "6zo-cloudtrail-logs"#cloudtrail의 로그를 저장할 s3
  #force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::6zo-cloudtrail-logs"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::6zo-cloudtrail-logs/AWSLogs/${var.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}

/*
첫 번째 Statement: S3 버킷 ACL 읽기 권한
=>CloudTrail이 S3 버킷에 로그를 저장하려면, 먼저 S3 버킷의 ACL(Access Control List)을 확인할 수 있어야 합니다.
 -"Sid": Statement 식별자-> AWSCloudTrailAclCheck로 지정되었습니다.
 -"Effect": 작업을 허용(Allow)하거나 거부(Deny)-> Allow로 설정해 권한을 부여합니다.
 -"Principal": 권한을 부여받는 주체를 지정 -> **CloudTrail 서비스(cloudtrail.amazonaws.com)**에 권한을 부여합니다.
 -"Action": 허용할 작업을 지정 -> s3:GetBucketAcl로, S3 버킷의 ACL을 읽는 작업을 허용합니다.
 -"Resource": 권한이 적용되는 S3 리소스를 지정-> S3 버킷의 ARN

두 번째 Statement: S3 버킷에 로그 쓰기 권한
=>CloudTrail이 로그 데이터를 S3 버킷에 저장하려면, 해당 경로에 쓰기 권한이 필요합니다.
 -"Sid": Statement 식별자입 -> AWSCloudTrailWrite로 지정되었습니다.
 -"Effect": 작업을 허용(Allow)합니다.
 -"Principal": 권한을 부여받는 주체로, CloudTrail 서비스(cloudtrail.amazonaws.com)를 지정
 -"Action": 허용할 작업은 s3:PutObject로, S3 버킷에 로그 객체를 쓰는 작업을 허용
 -"Resource": 권한이 적용되는 S3 리소스의 ARN입니다.
    예: arn:aws:s3:::my-cloudtrail-logs/AWSLogs/123456789012/*
    AWSLogs/${var.account_id}: CloudTrail 로그는 이 경로 아래에 저장됩니다.
 -"Condition": 추가 조건을 지정합니다.
    "s3:x-amz-acl": "bucket-owner-full-control": CloudTrail이 로그를 저장할 때, 
    S3 객체가 버킷 소유자가 모든 권한을 
    가지도록(bucket-owner-full-control) 설정되었는지를 확인합니다.*/



resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "cloudtrail-log-group" #cloudtrail의 로그를 저장할 cloudwatch의 로그 그룹
  retention_in_days = 90 #로그 유지 기간
}

# IAM 역할 생성 (CloudTrail이 CloudWatch 로그를 쓸 수 있도록 설정)
resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "cloudtrail_role_policy" {
  name = "cloudtrail-role-policy"
  role = aws_iam_role.cloudtrail_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:ap-northeast-2:195275677502:log-group:cloudtrail-log-group:*"
    }
  ]
}
POLICY
}

# CloudTrail 생성
resource "aws_cloudtrail" "main" {
  name                          = "ct-test" # CloudTrail 이름
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.bucket
  cloud_watch_logs_group_arn    = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudtrail_log_group_name}:*" # 동적 ARN
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true

  # 이벤트 선택기 추가 (S3 데이터 이벤트 추적)
  event_selector {
    read_write_type           = "All" # 모든 읽기/쓰기 작업 추적
    include_management_events = true # 관리 이벤트 포함
    data_resource {
      type   = "AWS::S3::Object" # S3 객체 수준의 데이터 추적
      values = ["arn:aws:s3:::6zo-cloudtrail-logs/"] # 추적할 S3 버킷 ARN
    }
  }
}



# 현재 AWS 리전 가져오기
data "aws_region" "current" {}

# 현재 AWS 계정 ID 가져오기
data "aws_caller_identity" "current" {}

#-----------guardduty-------
resource "aws_guardduty_detector" "main" {
  enable = true
}
#--버킷, guardduty, cloudtrail, cloudwatch logs 및 정책 생성--------

#-------------------------cloudwatch 기능-------------------------
# 로그 분석 및 탐지 후 전달할 이메일 설정
resource "aws_sns_topic" "security_alerts" {
  name = "SecurityAlerts"
}

# 이메일 구독 추가
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "rhwnahd7@naver.com" # 알림을 받을 이메일 주소
}

#비인가된 EC2 종료 시도
resource "aws_cloudwatch_log_metric_filter" "ec2_terminate_filter" {
  name           = "TerminateInstancesFilter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logs.name

  pattern = "{ $.eventName = \"TerminateInstances\" }" # EC2 종료 API 호출 감지

  metric_transformation {
    name      = "EC2TerminateAttempt"
    namespace = "CloudTrailLogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_terminate_alarm" {
  alarm_name          = "UnauthorizedEC2Termination"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.ec2_terminate_filter.metric_transformation[0].name
  namespace           = "CloudTrailLogs"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:SecurityAlerts"] # SNS 알림
}


# ---- 추가: 비정상적인 S3 접근 감지 ----
resource "aws_cloudwatch_log_metric_filter" "s3_access_filter" {
  name           = "S3AccessFilter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logs.name

  # GetObject 이벤트만 필터링
  pattern = "{ ($.eventName = \"GetObject\") && ($.sourceIPAddress != \"192.168.0.0/24\") }"

  metric_transformation {
    name      = "S3DownloadAttempt"
    namespace = "CloudTrailLogs"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "s3_access_alarm" {
  alarm_name          = "AbnormalS3Access"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.s3_access_filter.metric_transformation[0].name
  namespace           = "CloudTrailLogs"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:SecurityAlerts"] # SNS 알림
}


#------vpc 트래픽 로그 알림 기능 (cloudwatch만 이용, cloudtrail X)------
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 90

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination           = aws_cloudwatch_log_group.vpc_flow_logs.arn # CloudWatch Log Group 이름
  iam_role_arn             = aws_iam_role.flow_logs_role.arn
  vpc_id                   = var.vpc_id # vpc_id를 변수로 가져옴
  traffic_type             = "ALL" # "ALL", "ACCEPT", "REJECT" 중 선택 가능
}






# IAM 역할 생성
resource "aws_iam_role" "flow_logs_role" {
  name = "flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM 역할 정책 연결
resource "aws_iam_role_policy" "flow_logs_policy" {
  name   = "flow-logs-policy"
  role   = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 2. CloudWatch Metric Filter 생성 (예: 특정 IP에서 트래픽 감지)
resource "aws_cloudwatch_log_metric_filter" "specific_ip_filter" {
  depends_on     = [aws_cloudwatch_log_group.vpc_flow_logs] # 로그 그룹 생성 후 실행
  name           = "SpecificIPFilter"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name

  pattern = "172.217.25.174 ACCEPT"#####원하는 ip 대역 설정하기

  metric_transformation {
    name      = "ExternalIPAccess"
    namespace = "VPCFlowLogs"
    value     = "1"
  }
}

# 3. CloudWatch Alarm 생성 (예: 특정 IP에서 트래픽이 발생하면 알람)
resource "aws_cloudwatch_metric_alarm" "specific_ip_alarm" {
  alarm_name          = "SpecificIPTrafficAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.specific_ip_filter.metric_transformation[0].name
  namespace           = "VPCFlowLogs"
  period              = 60
  statistic           = "Sum"
  threshold           = 1 # 트래픽 이벤트가 5번 이상 발생하면 알람

  alarm_actions = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:SecurityAlerts"] # SNS 알림
}