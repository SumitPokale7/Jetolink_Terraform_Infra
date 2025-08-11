variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "default_security_group_id" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "aurora_master_password" {
  type      = string
  sensitive = true
}

variable "aurora_master_username" {
  type      = string
  sensitive = true
}

variable "backup_retention_period" {
  type = number
}

variable "preferred_backup_window" {
  type = string
}

variable "deletion_protection" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = true
    Owner     = "jetolink"
  }
}
