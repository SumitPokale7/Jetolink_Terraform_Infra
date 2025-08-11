data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_role" "bastion_kms_role" {
  name               = "jetolink-bastion-kms-role-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy" "kms_decrypt_policy" {
  name = "AllowKMSDecrypt"
  role = aws_iam_role.bastion_kms_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  role = aws_iam_role.bastion_kms_role.name
  name = "jetolink-bastion-instance-profile-${terraform.workspace}"
}

resource "tls_private_key" "bastion_key" {
  rsa_bits  = 4096
  algorithm = "RSA"
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "jetolink-bastion-key-${terraform.workspace}"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_instance" "bastion" {
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnets[0]
  ami                         = data.aws_ami.amazon_linux_2.id
  key_name                    = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name

  tags = merge(
    {
      Name = "bastion-${terraform.workspace}",
    },
    var.tags
  )

  user_data = <<-EOF
    #!/bin/bash
    yum update -y

    # Enable the PostgreSQL 10 repo & Java
    amazon-linux-extras enable postgresql10
    amazon-linux-extras enable corretto11
    
    # Install PostgreSQL client & Java tools
    yum install -y postgresql
    psql --version
    yum install -y java-11-amazon-corretto

    # Install dependencies for SOPS
    yum install -y curl
    yum install -y jq

    # Download latest SOPS binary
    curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64

    # Move it to /usr/local/bin
    mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops

    # Give Permissions
    chmod +x /usr/local/bin/sops
    sops --version

    # Install Kafka cli tools
    wget https://archive.apache.org/dist/kafka/3.3.1/kafka_2.12-3.3.1.tgz
    tar -xzf kafka_2.12-3.3.1.tgz
  EOF

  lifecycle {
    ignore_changes = [ 
      associate_public_ip_address
    ]
  }
}
