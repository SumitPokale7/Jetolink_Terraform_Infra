# Create ECR repositories for jetolink services
resource "aws_ecr_repository" "jetolink_ecr_repos" {
  for_each = var.jetolink_ecr_repos

  # Enable encryption at rest using AES256 (default AWS-managed key)
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Enable image scanning on push if defined in input variable
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  # Allow image tags to be mutable (can be overwritten)
  image_tag_mutability = "MUTABLE"

  # Repository name includes the workspace (e.g., dev, prod)
  name = "${each.key}/${terraform.workspace}"

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "ECR-repos-${terraform.workspace}"
    },
    var.tags
  )
}
