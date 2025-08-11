output "codebuild_project_arns" {
  value = [for project in aws_codebuild_project.aws_codebuild : project.arn]
}
