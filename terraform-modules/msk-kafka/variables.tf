variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "bastion_security_group_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "kafka_instance_type" {
  type    = string
  default = "kafka.t3.small"
}

variable "broker_count" {
  type        = number
  description = "Number of broker to be deployed"
}

variable "kafka_version" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = true
    Environment = "dev"
    Owner       = "jetolink"
  }
}
