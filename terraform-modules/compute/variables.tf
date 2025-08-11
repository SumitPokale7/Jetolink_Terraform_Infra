variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(any)
}

variable "lb_type" {
  type    = string
  default = "application"
}

variable "hosted_zone_id" {
  type = string
}

variable "acm_certificate" {
  type = string
}

variable "ecs_services" {
  type = any
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = true
    Environment = "dev"
    Owner       = "jetolink"
  }
}
