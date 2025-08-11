variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "default_security_group_id" {
  type = list(string)
}

variable "target_group_arns" {
  type = map(string)
}

variable "ecs_services" {
  type = map(object({
    portMappings = list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
    }))
    cpu                     = string
    memory                  = string
    operating_system_family = string
    cpu_architecture        = string
    secrets                 = list(map(string))
    environment             = list(map(string))
    healthCheck             = any
  }))
}

variable "jetolink_ecr_repos" {
  type = map(any)
}

variable "aws_iam_policy_settings" {
  description = "AWS IAM policy settings"
  default     = {}
  type = map(object({
    actions   = list(string)
    resources = list(string)
  }))
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = true
    Environment = "dev"
    Owner       = "jetolink"
  }
}
