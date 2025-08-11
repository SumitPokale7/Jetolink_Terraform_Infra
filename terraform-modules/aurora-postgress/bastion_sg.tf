# Creates a security group for the Bastion host
resource "aws_security_group" "bastion_sg" {
  vpc_id      = var.vpc_id
  name        = "bastion-sg-${terraform.workspace}"
  description = "Allow SSH and outbound DB access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from allowed IPs"
  }

  # Outbound rule to allow all outbound traffic (default behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    {
      Name = "bastion-sg-${terraform.workspace}",
    },
    var.tags
  )
}

# Configures the AWS provider with a named alias for use in cross-account or multi-provider setups
terraform {
  required_providers {
    aws = {
      version               = "~> 5.0"
      configuration_aliases = [aws.mgmt] # Used for cross-account rule attachment
      source                = "hashicorp/aws"
    }
  }
}

# Creates a security group rule in the "mgmt" account to allow Bastion SG to access PostgreSQL DB port
resource "aws_security_group_rule" "allow_bastion_to_rds" {
  provider = aws.mgmt # Uses the aliased provider for target account

  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = aws_security_group.bastion_sg.id         # Bastion SG as the source
  security_group_id        = tolist(var.default_security_group_id)[0] # RDS SG as the target
  description              = "Allow Bastion host to connect to Aurora PostgreSQL"
}
