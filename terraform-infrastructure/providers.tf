terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    encrypt        = true
    region         = "us-east-1"
    bucket         = "jetolink-mgmt-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    dynamodb_table = "jetolink-mgmt-terraform-lock-table"

    assume_role = {
      role_arn = "arn:aws:iam::777446362975:role/TerraformAccessRole"
    }
  }
}

provider "aws" {
  alias  = "mgmt"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::777446362975:role/TerraformAccessRole"
  }
}

provider "aws" {
  region  = var.region
  # profile = terraform.workspace
}
