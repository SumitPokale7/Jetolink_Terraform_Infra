output "aws_rds_cluster" {
  value = aws_rds_cluster.this.arn
}

output "aurora_postgres_endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
