data "aws_caller_identity" "this" {}

resource "aws_kms_key" "state" {
  tags        = local.tags
  description = "Terraform S3 remote state KMS key."
}

resource "aws_kms_alias" "state" {
  target_key_id = aws_kms_key.state.key_id
  name          = "alias/jetolink/terraform-${terraform.workspace}/state"
}

resource "aws_s3_bucket" "terraform_state" {
  tags   = local.tags
  bucket = var.backend_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_cross_account_access" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountsToUseBucket"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::159773342471:root",
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.backend_bucket_name}/*",
          "arn:aws:s3:::${var.backend_bucket_name}"
        ]
      }
    ]
  })
}


resource "aws_dynamodb_table" "terraform_lock" {
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"
  name           = var.backend_dynamodb_table

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}

resource "aws_iam_role" "terraform_cross_account" {
  name = "TerraformAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::159773342471:root"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_backend_access" {
  name        = "TerraformBackendAccessPolicy"
  description = "Allow Terraform cross-account access to S3, DynamoDB, and KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.backend_bucket_name}",
          "arn:aws:s3:::${var.backend_bucket_name}/*"
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.this.account_id}:table/${var.backend_dynamodb_table}"
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "arn:aws:kms:us-east-1:${data.aws_caller_identity.this.account_id}:key/${aws_kms_key.state.key_id}"
      },
      {
        Sid    = "OtherAccess"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "ram:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backend_policy" {
  role       = aws_iam_role.terraform_cross_account.name
  policy_arn = aws_iam_policy.terraform_backend_access.arn
}
