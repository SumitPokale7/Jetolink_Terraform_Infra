terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # profile        = "mgmt" # Uncomment to use profile
    encrypt        = true
    region         = "us-east-1"
    key            = "network/terraform.tfstate"
    bucket         = "jetolink-mgmt-terraform-state"
    dynamodb_table = "jetolink-mgmt-terraform-lock-table"
  }
}

provider "aws" {
  region = var.region
    # profile = "mgmt" # Uncomment to use profile
}
