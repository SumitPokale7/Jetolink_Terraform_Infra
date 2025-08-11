terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = "~> 5.0"
  }

  backend "s3" {
    encrypt        = true
    region         = "us-east-1"
    key            = "pipelines/terraform.tfstate"
    bucket         = "jetolink-mgmt-terraform-state"
    dynamodb_table = "jetolink-mgmt-terraform-lock-table"

    assume_role = {
      role_arn = "arn:aws:iam::777446362975:role/TerraformAccessRole"
    }
  }
}

provider "aws" {
  region = var.region
  # profile = terraform.workspace
}
