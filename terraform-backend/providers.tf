terraform {
  backend "s3" {
    # profile        = "mgmt" # Uncomment to use profile
    encrypt        = true
    region         = "us-east-1"
    key            = "terraform-backend/backend.tfstate"
    bucket         = "jetolink-mgmt-terraform-state"
    dynamodb_table = "jetolink-mgmt-terraform-lock-table"
  }
}

terraform {
  required_providers {
    aws = "~> 5.0"
  }
  required_version = ">= 1.12.2"
}

provider "aws" {
  region = var.region
  # profile = "mgmt" # Uncomment to use profile
}
