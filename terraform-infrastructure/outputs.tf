#Network
output "vpc_id" {
  value = data.terraform_remote_state.network.outputs.vpc_id
}

output "private_subnets" {
  value = data.terraform_remote_state.network.outputs.private_subnets
}

output "public_subnets" {
  value = data.terraform_remote_state.network.outputs.public_subnets
}

#S3
output "bucket_arn" {
  value = module.s3.bucket_arns
}

#
output "ecs_cluster_name" {
  value = module.container.cluster_name
}

output "ecs_cluster_id" {
  value = module.container.cluster_id
}

output "ecs_task_execution_role_arn" {
  value = module.container.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  value = module.container.ecs_task_role_arn
}

output "ecs_sg_id" {
  value = module.container.ecs_sg_id
}

#Compute
output "target_group_arns" {
  value = module.compute.target_group_arns
}

output "alb_http_listeners" {
  value = module.compute.alb_http_listeners
}

output "alb_https_listeners" {
  value = module.compute.alb_https_listeners
}

output "alb_arn" {
  value = module.compute.alb_arn
}

output "alb_dns" {
  value = module.compute.alb_dns
}

#Postgress
output "aws_rds_cluster" {
  value = module.postgres.aws_rds_cluster
}

output "aurora_postgres_endpoint" {
  value = module.postgres.aurora_postgres_endpoint
}

#Redis
output "redis_endpoint" {
  value = module.redis.redis_endpoint
}

#MSK Kafka
output "zookeeper_connect_string_tls" {
  value = module.msk-kafka.zookeeper_connect_string_tls
}
output "bootstrap_brokers_tls" {
  value = module.msk-kafka.bootstrap_brokers_tls
}
