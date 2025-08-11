output "cluster_name" {
  value = aws_ecs_cluster.jetolink_ecs_cluster.name
}

output "cluster_id" {
  value = aws_ecs_cluster.jetolink_ecs_cluster.id
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_sg_id" {
  value = aws_security_group.allow_traffic_to_container.id
}
