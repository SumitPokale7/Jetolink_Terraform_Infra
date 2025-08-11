resource "aws_iam_role" "codebuild" {
  tags               = var.tags
  name               = "codebuild-service-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.codepipeline.arn]
    }
  }
}

resource "aws_iam_role_policy" "codebuild_passrole" {
  role = aws_iam_role.codebuild.id
  name = "codebuild-passrole-policy-${terraform.workspace}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPassRoleToECS"
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          "arn:aws:iam::159773342471:role/ecs-task-role-dev",
          "arn:aws:iam::159773342471:role/ecs-task-execution-role-dev"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_logging" {
  role = aws_iam_role.codebuild.id
  name = "codebuild-logging-policy-${terraform.workspace}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "CloudWatchLogsPolicy",
        Effect : "Allow",
        Action : [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        Resource : [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_extra" {
  role = aws_iam_role.codebuild.id
  name = "codebuild-extra-policy-${terraform.workspace}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "cloudwatch:PutMetricData",
          "sts:GetCallerIdentity",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_ecr" {
  role = aws_iam_role.codebuild.id
  name = "codebuild-ecr-policy-${terraform.workspace}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline" {
  tags               = var.tags
  description        = "Service role for CodePipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  name               = "jetolink-codepipeline-service-role-${terraform.workspace}"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  for_each = var.apps
  role     = aws_iam_role.codepipeline.id
  policy   = data.aws_iam_policy_document.codepipeline_policy[each.key].json
  name     = "jetolink-codepipeline-inlinepolicy-${each.key}-${terraform.workspace}"
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  for_each = var.apps

  statement {
    sid = "S3ArtifactBucketAccess"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::*-artifacts-*",
      "arn:aws:s3:::*-artifacts-*/*"
    ]
  }

  statement {
    sid       = "PassRoleToCodeBuild"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.codebuild.arn]
  }

  statement {
    sid       = "UseGitHubConnection"
    actions   = ["codestar-connections:UseConnection"]
    resources = [data.aws_codestarconnections_connection.github.arn]
  }

  statement {
    sid = "ManageCodeBuildBuilds"
    actions = [
      "codebuild:StopBuild",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = [
      aws_codebuild_project.aws_codebuild[each.key].arn
    ]
  }

  statement {
    sid = "AllowECSDeploy"
    actions = [
      "ecs:*",
    ]
    resources = ["*"]
  }

  statement {
    sid     = "AllowPassRoleToECS"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::159773342471:role/ecs-task-role-dev",
      "arn:aws:iam::159773342471:role/ecs-task-execution-role-dev"
    ]
  }
}
