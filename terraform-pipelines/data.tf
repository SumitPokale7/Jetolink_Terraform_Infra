data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "jetolink-mgmt-terraform-state"
    key    = "env:/${terraform.workspace}/infrastructure/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}
