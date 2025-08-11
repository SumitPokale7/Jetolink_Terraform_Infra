data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "jetolink-mgmt-terraform-state"
    key    = "env:/${terraform.workspace}/network/terraform.tfstate"
  }
}

data "terraform_remote_state" "global_resources" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "jetolink-mgmt-terraform-state"
    key    = "env:/${terraform.workspace}/global_resources/terraform.tfstate"
  }
}
