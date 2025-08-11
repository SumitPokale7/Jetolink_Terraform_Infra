# Security group for MSK cluster, used to control inbound/outbound traffic
resource "aws_security_group" "msk_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for MSK cluster"
  name        = "msk-cluster-sg-${terraform.workspace}"

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "jetolink-msk-kafka-sg-${terraform.workspace}"
    },
    var.tags
  )
}

# Ingress rule to allow traffic from internal VPC resources to MSK brokers
resource "aws_security_group_rule" "allow_msk_broker_internal" {
  from_port                = 0
  protocol                 = "tcp"
  to_port                  = 65535
  type                     = "ingress"
  source_security_group_id = var.ecs_security_group_id
  security_group_id        = aws_security_group.msk_sg.id
  description              = "Allow internal communication from within VPC"
}

resource "aws_security_group_rule" "allow_msk_broker_bastion" {
  from_port                = 0
  protocol                 = "tcp"
  to_port                  = 65535
  type                     = "ingress"
  source_security_group_id = var.bastion_security_group_id
  security_group_id        = aws_security_group.msk_sg.id
  description              = "Allow internal communication from within VPC"
}

# Egress rule to allow all outbound traffic from the MSK security group
resource "aws_security_group_rule" "egress_all" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.msk_sg.id
}
