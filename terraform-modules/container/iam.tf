data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs_task_role_document" {
  dynamic "statement" {
    for_each = var.aws_iam_policy_settings

    content {
      effect    = "Allow"
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name   = "ecs-task-role-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task_role_document.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_role_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "execution_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution_extra" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ecs_task_execution_extra_policy" {
  name   = "ecs-task-execution-extra-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task_execution_extra.json
}

resource "aws_iam_role_policy_attachment" "execution_extra_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_extra_policy.arn
}

data "aws_iam_policy_document" "ecs_task_execution_ecr_auth" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_execution_ecr_auth_policy" {
  name   = "ecs-task-execution-ecr-auth-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task_execution_ecr_auth.json
}

resource "aws_iam_role_policy_attachment" "execution_ecr_auth_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_ecr_auth_policy.arn
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name   = "ecs-task-execution-policy-${terraform.workspace}"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}
