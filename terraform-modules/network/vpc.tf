module "vpc" {
  source                        = "terraform-aws-modules/vpc/aws"
  version                       = "5.21.0"
  manage_default_security_group = true
  azs                           = var.azs
  cidr                          = var.vpc_cidr
  enable_nat_gateway            = var.enable_nat_gateway
  single_nat_gateway            = var.single_nat_gateway
  public_subnets                = var.public_subnet_cidrs
  private_subnets               = var.private_subnets_cidrs
  name                          = "${var.vpc_name}-${terraform.workspace}"
  tags = merge(
    {
      Name         = "Central-VPC-${terraform.workspace}",
      Environement = terraform.workspace
    },
    var.tags
  )
}

resource "aws_security_group" "vpc_sg" {
  vpc_id      = module.vpc.vpc_id
  description = "Allow traffic to VPC SG"
  name        = "jetolink-sg-${terraform.workspace}"

  dynamic "ingress" {
    for_each = [
      for rule in var.default_security_group_ingress : merge(rule, {
        cidr_blocks = [var.vpc_cidr]
      })
    ]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  tags = merge(
    {
      Name         = "VPC-SG-${terraform.workspace}",
      Environement = terraform.workspace
    },
    var.tags
  )
}
