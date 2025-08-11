# Security group to allow public internet traffic (HTTP/HTTPS) for the ALB
resource "aws_security_group" "allow_traffic" {
  vpc_id      = var.vpc_id
  description = "jetolink allow internet traffic"
  name        = "jetolink-allow-internet-traffic-${terraform.workspace}"

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Environment = terraform.workspace
      Name        = "jetolink-allow-internet-traffic-${terraform.workspace}"
    },
    var.tags
  )
}
