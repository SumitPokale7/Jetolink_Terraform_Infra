# Create individual CloudWatch log groups per ECS service
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  for_each          = var.ecs_services
  name              = "/ecs/${each.key}-${terraform.workspace}"
  retention_in_days = 7

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "CloudWatch-LogGroup-${terraform.workspace}"
    },
    var.tags
  )
}

# Define the ECS Cluster for the environment
resource "aws_ecs_cluster" "jetolink_ecs_cluster" {
  name = "jetolink-ecs-${terraform.workspace}"

  # Enable Container Insights monitoring
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "ECS-Cluster-${terraform.workspace}"
    },
    var.tags
  )
}

# Attach FARGATE and FARGATE_SPOT capacity providers to the ECS cluster
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  cluster_name       = aws_ecs_cluster.jetolink_ecs_cluster.name
}

# Define ECS Task Definitions for each service
resource "aws_ecs_task_definition" "this" {
  for_each = var.ecs_services

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  family                   = "${each.key}-${terraform.workspace}"

  container_definitions = jsonencode([
    {
      name           = "${each.key}-${terraform.workspace}"
      image          = "${aws_ecr_repository.jetolink_ecr_repos[each.key].repository_url}:latest"
      portMappings   = each.value.portMappings
      secrets        = each.value.secrets
      environment    = each.value.environment
      mountPoints    = []
      volumesFrom    = []
      systemControls = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-stream-prefix = "ecs"
          awslogs-region        = var.region
          awslogs-group         = "/ecs/${each.key}-${terraform.workspace}"
        }
      }
      healthCheck = each.value.healthCheck
    }
  ])

  runtime_platform {
    cpu_architecture        = each.value.cpu_architecture
    operating_system_family = each.value.operating_system_family
  }

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "ECS-TaskDefinition-${terraform.workspace}"
    },
    var.tags
  )

  depends_on = [aws_ecr_repository.jetolink_ecr_repos]
}

# Create ECS Services for each task definition
resource "aws_ecs_service" "ecs_service" {
  for_each               = var.ecs_services
  name                   = "${each.key}-${terraform.workspace}"
  cluster                = aws_ecs_cluster.jetolink_ecs_cluster.id
  task_definition        = aws_ecs_task_definition.this[each.key].arn
  desired_count          = 1
  enable_execute_command = true
  force_new_deployment   = false
  launch_type            = "FARGATE"

  # Networking setup for the ECS service
  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.allow_traffic_to_container.id]
  }

  # Attach the service to the target group for load balancing
  dynamic "load_balancer" {
    for_each = [1] # enables block even for one target group per service
    content {
      container_name   = "${each.key}-${terraform.workspace}"
      container_port   = each.value.portMappings[0].containerPort
      target_group_arn = var.target_group_arns["${each.key}-${terraform.workspace}"]
    }
  }

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "ECS-Service-${terraform.workspace}"
    },
    var.tags
  )

  depends_on = [aws_ecs_task_definition.this]
}
