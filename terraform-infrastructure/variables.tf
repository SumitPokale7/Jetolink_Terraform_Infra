#Common
variable "region" {
  type    = string
  default = "us-east-1"
}

#Container
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
    alb_health_check = list(object({
      path                = string
      matcher             = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    }))
  }))
}

#Postgress
variable "rds_instance_class" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
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

#Redis
variable "cluster_size" {
  type = number
}

variable "redis_engine" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "redis_instance_type" {
  type = string
}

variable "family" {
  type = string
}

variable "redis_engine_version" {
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

#Msk Kafka
variable "kafka_instance_type" {
  type = string
}

variable "broker_count" {
  type        = number
  description = "Number of broker to be deployed"
}

variable "kafka_version" {
  type = string
}
