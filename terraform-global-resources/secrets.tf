# Postgres
resource "aws_kms_key" "postgres_encryption_key" {
  deletion_window_in_days = 7
  enable_key_rotation     = true
  description             = "KMS key for encryption and decryption Aurora Postgres secrets"

  tags = merge(
    var.tags,
    {
      Environment = terraform.workspace
    }
  )
}

resource "aws_kms_alias" "postgres_encryption_key_alias" {
  name          = "alias/aurora-postgres-encryption-key-${terraform.workspace}"
  target_key_id = aws_kms_key.postgres_encryption_key.id
}

# Postgres Secrets
resource "aws_secretsmanager_secret" "db_secret" {
  name = "jetolink-aurora-postgres-DB-secret-${terraform.workspace}"

  tags = merge(
    var.tags,
    {
      Environment = terraform.workspace
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.rds_master_username
    password = var.rds_master_password
  })
}
