region            = "us-east-1"
github_connection = "jetolink_github_connection"

tags = {
  Environment = "dev"
  Terraform   = "true"
  Owner       = "jetolink"
}

apps = {
  jetolink_terraform_dev = {
    branch      = "dev"
    buildspec   = "buildspec-dev.yml"
    repo_name   = "jetolink_terraform"
    bucket_name = "jetolink-terraform"
  }

  jetolink_chat_service_dev = {
    buildspec    = "buildspec-dev.yaml"
    branch       = "feature/devops-sanket"
    repo_name    = "jetolink_chat_service"
    bucket_name  = "jetolink-chat-service"
    service_name = "jetolink-chat-service-dev"
  }
}
