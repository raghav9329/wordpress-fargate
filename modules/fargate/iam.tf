# ECS assume role policy for IAM role
data "aws_iam_policy_document" "ecs-assume-role-policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name   = "${local.app_name}-IAM-Role-Policy"
  role   = aws_iam_role.ecs_cluster_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:*",
        "ecs:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "dynamodb:*",
        "cloudwatch:*",
        "s3:*",
        "rds:*",
        "elasticfilesystem:*",
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# ECS task execution role
resource "aws_iam_role" "ecs_cluster_role" {
  name               = "${local.app_name}-IAM-Role"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
}

