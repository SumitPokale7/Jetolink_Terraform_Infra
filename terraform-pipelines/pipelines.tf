data "aws_codestarconnections_connection" "github" {
  name = var.github_connection
}

resource "aws_cloudwatch_log_group" "codebuild_logs" {
  tags = var.tags
  name = "jetolink-codebuild-log-${terraform.workspace}"
}

resource "aws_codebuild_project" "aws_codebuild" {
  for_each     = var.apps
  service_role = aws_iam_role.codebuild.arn
  name         = "${each.value.repo_name}-build-${terraform.workspace}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_logs.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = each.value.buildspec
  }
  tags = var.tags
}

resource "aws_codepipeline" "aws_pipeline" {
  for_each = var.apps
  role_arn = aws_iam_role.codepipeline.arn
  name     = "${each.value.repo_name}-build-${terraform.workspace}"

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3_buckets[each.key].bucket
  }

  stage {
    name = "Source"
    action {
      version          = "1"
      owner            = "AWS"
      category         = "Source"
      name             = "Source"
      output_artifacts = ["SourceArtifact"]
      provider         = "CodeStarSourceConnection"

      configuration = {
        BranchName       = "${each.value.branch}"
        FullRepositoryId = "Jetolink/${each.value.repo_name}"
        ConnectionArn    = data.aws_codestarconnections_connection.github.arn
      }
    }
  }

  stage {
    name = "Build"
    action {
      version          = "1"
      owner            = "AWS"
      category         = "Build"
      name             = "Build"
      provider         = "CodeBuild"
      output_artifacts = ["build_output"]
      input_artifacts  = ["SourceArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.aws_codebuild[each.key].name
      }
    }
  }

  dynamic "stage" {
    for_each = each.key == "jetolink_chat_service_${terraform.workspace}" ? [1] : []
    content {
      name = "Deploy_to_ECS"
      action {
        version         = 1
        run_order       = 1
        owner           = "AWS"
        provider        = "ECS"
        category        = "Deploy"
        name            = "ECS_Deploy"
        input_artifacts = ["build_output"]
        configuration = {
          DeploymentTimeout = "15"
          FileName          = "imagedefinitions.json"
          ServiceName       = "${each.value.service_name}"
          ClusterName       = data.terraform_remote_state.infrastructure.outputs.ecs_cluster_name
        }
        role_arn = aws_iam_role.codepipeline.arn
      }
    }
  }
}
