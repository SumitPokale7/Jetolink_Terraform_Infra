# Security group to allow ALB to reach ECS containers on their respective container ports
resource "aws_security_group" "allow_traffic_to_container" {
  vpc_id      = var.vpc_id
  description = "Allow HTTP traffic"
  name        = "jetolink-allow-http-traffic-${terraform.workspace}"

  # Dynamically allow ingress for each container port from the ALB security group
  dynamic "ingress" {
    for_each = toset(flatten([
      for svc in var.ecs_services : [
        for mapping in svc.portMappings : mapping.containerPort
      ]
    ]))
    content {
      protocol        = "tcp"
      security_groups = [var.alb_sg]  # ALB SG as the source
      from_port       = ingress.value
      to_port         = ingress.value
    }
  }

  # Allow all outbound traffic from ECS tasks
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "allow-traffic-container-${terraform.workspace}"
    },
    var.tags
  )
}

# AWS provider with an alias for management account (used for cross-account SG rule)
terraform {
  required_providers {
    aws = {
      version               = "~> 5.0"
      configuration_aliases = [aws.mgmt]
      source                = "hashicorp/aws"
    }
  }
}

# Add rule in default SG (in mgmt account) to allow all TCP from ECS container SG
resource "aws_security_group_rule" "ecs_to_services" {
  provider                 = aws.mgmt
  from_port                = 0
  protocol                 = "tcp"
  to_port                  = 65535
  type                     = "ingress"
  security_group_id        = var.default_security_group_id[0]
  description              = "Allow all TCP from ECS containers"
  source_security_group_id = aws_security_group.allow_traffic_to_container.id
}
