variable "region" {
  type    = string
  default = "us-east-1"
}

variable "route53_zone" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ssm_parameters" {
  type = map(object({
    value  = string
    type   = string
    key_id = optional(string)
  }))
}

variable "rds_master_username" {
  type        = string
  description = "Master username for the RDS instance"
}

variable "rds_master_password" {
  type        = string
  description = "Master password for the RDS instance"
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = true
    Owner     = "jetolink"
  }
}
