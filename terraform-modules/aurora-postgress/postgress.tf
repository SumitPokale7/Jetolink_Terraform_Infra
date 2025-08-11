# Create a DB Subnet Group using private subnets
resource "aws_db_subnet_group" "this" {
  tags       = var.tags
  subnet_ids = var.private_subnets
  name       = "jetolink-subnet-group-${terraform.workspace}"
}

# Create a Security Group for RDS to allow PostgreSQL traffic within the VPC
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  name   = "jetolink-rds-${terraform.workspace}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "jetolink-rds-sg-${terraform.workspace}"
    },
    var.tags
  )
}

# Create a global RDS cluster only in the production environment
resource "aws_rds_global_cluster" "this" {
  count                     = terraform.workspace == "prod" ? 1 : 0
  global_cluster_identifier = "jetolink-global-rds-prod"
  engine                    = var.engine
}

# Create the RDS Cluster (Aurora)
resource "aws_rds_cluster" "this" {
  engine             = var.engine
  engine_version     = var.engine_version
  cluster_identifier = "jetolink-rds-${terraform.workspace}"

  master_username = var.aurora_master_username
  master_password = var.aurora_master_password

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "final-snapshot-${terraform.workspace}-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window

  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]

  # Only attach global cluster in production
  global_cluster_identifier = terraform.workspace == "prod" ? aws_rds_global_cluster.this[0].id : null

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "RDS-Cluster-${terraform.workspace}"
    },
    var.tags
  )
}

# Create RDS Cluster Instances (2 instances for HA)
resource "aws_rds_cluster_instance" "this" {
  count              = 2
  instance_class     = var.rds_instance_class
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  identifier         = "jetolink-rds-instance-${terraform.workspace}-${count.index + 1}"

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "RDS-Cluster-Instance-${terraform.workspace}"
    },
    var.tags
  )
}

# Upload secrets.json file to the Bastion host
resource "null_resource" "upload__secret_file" {
  depends_on = [aws_instance.bastion]
  provisioner "file" {
    connection {
      user        = "ec2-user"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }

    source      = "${path.module}/secrets_${terraform.workspace}.json"
    destination = "/home/ec2-user/secrets_${terraform.workspace}.json"
  }
}

# Upload bootstrap.sh script to the Bastion host
resource "null_resource" "upload_bootstrap_file" {
  depends_on = [aws_instance.bastion]
  provisioner "file" {
    connection {
      user        = "ec2-user"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }

    source      = "${path.module}/bootstrap.sh"
    destination = "/home/ec2-user/bootstrap.sh"
  }
}

# Execute the bootstrap.sh script on the Bastion to create the databases
resource "null_resource" "create_databases" {
  depends_on = [
    aws_instance.bastion,
    aws_rds_cluster.this,
    aws_rds_cluster_instance.this,
    null_resource.upload__secret_file,
    null_resource.upload_bootstrap_file
  ]

  provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }

    inline = [
      "chmod +x /home/ec2-user/bootstrap.sh",
      "export DB_HOST='${aws_rds_cluster.this.endpoint}'",
      "export TF_WORKSPACE='${terraform.workspace}'",
      "export DEFAULT_DB_USER='${var.aurora_master_username}'",
      "export DEFAULT_DB_PASS='${var.aurora_master_password}'",
      "/home/ec2-user/bootstrap.sh",
      "sleep 60",
    ]
  }
}

resource "aws_ec2_instance_state" "change_to_stop" {
  state       = "stopped"
  instance_id = aws_instance.bastion.id

  depends_on = [ null_resource.create_databases ]
}
