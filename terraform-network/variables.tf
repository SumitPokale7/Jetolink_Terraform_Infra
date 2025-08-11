variable "region" {
  type    = string
  default = "us-east-1"
}

#Network
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "public_subnet_cidrs" {
  type = list(any)
}

variable "private_subnets_cidrs" {
  type = list(any)
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "single_nat_gateway" {
  type    = bool
  default = false
}

variable "default_security_group_ingress" {
  type = list(map(string))
}

variable "aws_ram_resource_share_name" {
  type = string
}

variable "account_numbers" {
  type = set(string)
}

variable "tags" {
  default = {
    SharedBy  = "mgmt"
    Terraform = "true"
    Owner     = "jetolink"
  }
}
