variable "vpc_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "default_security_group_id" {
  type = list(string)
}

variable "cluster_size" {
  type = number
}

variable "redis_instance_type" {
  type = string
}

variable "redis_engine" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "family" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "num_node_groups" {
  type = number
}

variable "replicas_per_node_group" {
  type = number
}

variable "automatic_failover_enabled" {
  type = bool
}

variable "multi_az_enabled" {
  type = bool
}

variable "transit_encryption_enabled" {
  type = bool
}

variable "at_rest_encryption_enabled" {
  type = bool
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = true
    Environment = "dev"
    Owner       = "jetolink"
  }
}
