

resource "aws_iam_role_policy" "ssm-acces" {
  name = "test-policy"
  role = aws_iam_role.assume_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:PutMetricData",
            "ds:CreateComputer",
            "ds:DescribeDirectories",
            "ec2:DescribeInstanceStatus",
            "logs:*",
            "ssm:*",
            "ec2messages:*"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*",
          "Condition" : {
            "StringLike" : {
              "iam:AWSServiceName" : "ssm.amazonaws.com"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "iam:DeleteServiceLinkedRole",
            "iam:GetServiceLinkedRoleDeletionStatus"
          ],
          "Resource" : "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "assume_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_instance_profile" "ssm-profile" {
  name = "ssm-profile"
  role = aws_iam_role.assume_role.name
}