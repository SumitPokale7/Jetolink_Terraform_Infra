# ALB module to provision Application Load Balancer and associated target groups
module "alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "~> 8.0"
  enable_deletion_protection = false
  vpc_id                     = var.vpc_id
  subnets                    = var.public_subnets
  name                       = "jetolink-alb-${terraform.workspace}"
  security_groups            = [aws_security_group.allow_traffic.id]

  target_groups = [
    for name, svc in var.ecs_services : {
      target_type      = "ip"
      backend_protocol = "HTTP"
      name             = "${name}-${terraform.workspace}"
      backend_port     = svc.portMappings[0].containerPort

      health_check = {
        enabled             = true
        protocol            = "HTTP"
        port                = "traffic-port"
        path                = svc.alb_health_check[0].path
        matcher             = svc.alb_health_check[0].matcher
        timeout             = svc.alb_health_check[0].timeout
        interval            = svc.alb_health_check[0].interval
        healthy_threshold   = svc.alb_health_check[0].healthy_threshold
        unhealthy_threshold = svc.alb_health_check[0].unhealthy_threshold
      }
    }
  ]

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "jetolink-alb-${terraform.workspace}"
    },
    var.tags
  )

  depends_on = [
    aws_security_group.allow_traffic,
  ]
}

# HTTPS listener on port 443 with default forwarding to frontend target group
resource "aws_lb_listener" "https_listener" {
  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = module.alb.lb_arn
  certificate_arn   = var.acm_certificate

  default_action {
    type = "forward"
    target_group_arn = module.alb.target_group_arns[
      index(module.alb.target_group_names, "jetolink-frontend-${terraform.workspace}")
    ]
  }

  depends_on = [module.alb]
}

# HTTP listener on port 80 with default forwarding to frontend target group
resource "aws_lb_listener" "http_listener" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = module.alb.lb_arn

  default_action {
    type = "forward"
    target_group_arn = module.alb.target_group_arns[
      index(module.alb.target_group_names, "jetolink-frontend-${terraform.workspace}")
    ]
  }

  depends_on = [module.alb]
}

# HTTPS rule to match the Host header for frontend service
resource "aws_lb_listener_rule" "https_host_header_rule" {
  priority     = 100
  listener_arn = aws_lb_listener.https_listener.arn

  condition {
    host_header {
      values = ["frontend.jetolink.com"]
    }
  }

  action {
    type = "forward"
    target_group_arn = module.alb.target_group_arns[
      index(module.alb.target_group_names, "jetolink-frontend-${terraform.workspace}")
    ]
  }
}

# HTTPS listener rules for path-based routing to services other than frontend
resource "aws_lb_listener_rule" "https_service_rules" {
  for_each = {
    for name, svc in var.ecs_services : name => svc
    if name != "jetolink-frontend"
  }

  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200 + index(keys(var.ecs_services), each.key)

  condition {
    path_pattern {
      values = ["/${each.key}/*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = element(
      module.alb.target_group_arns,
      index(keys(var.ecs_services), each.key)
    )
  }
}

# HTTP listener rules for path-based routing to services other than frontend
resource "aws_lb_listener_rule" "http_service_rules" {
  for_each = {
    for name, svc in var.ecs_services : name => svc
    if name != "jetolink-frontend"
  }

  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 300 + index(keys(var.ecs_services), each.key)

  condition {
    path_pattern {
      values = ["/${each.key}/*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = element(
      module.alb.target_group_arns,
      index(keys(var.ecs_services), each.key)
    )
  }
}

# Update the SSM Parameter when the ALB DNS Name Changes
# Local variables to define ALB DNS and SSM parameter mappings
locals {
  alb_dns_name = module.alb.lb_dns_name

  ssm_parameters = {
    "NEXT_PUBLIC_BACKEND_URL-frontend-${terraform.workspace}" = {
      path = "/jetolink-backend"
    },
    "NEXT_PUBLIC_SOCKET_URL-frontend-${terraform.workspace}" = {
      path = "/jetolink-chat-service"
    },
    "BACKEND_URL-chat-service-${terraform.workspace}" = {
      path = "/jetolink-backend/api/v1"
    }
  }
}

# Create SSM parameters for frontend and chat-service URLs
resource "aws_ssm_parameter" "params" {
  for_each = local.ssm_parameters

  name  = each.key
  type  = "String"
  value = "http://${local.alb_dns_name}${each.value.path}"

  overwrite = true

  tags = merge(
    var.tags,
    {
      Environment = terraform.workspace
    }
  )

  depends_on = [module.alb]
}
