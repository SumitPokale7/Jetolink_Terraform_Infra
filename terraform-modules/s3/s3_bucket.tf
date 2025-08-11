data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3_buckets" {
  for_each            = var.buckets
  bucket              = "${each.key}-${terraform.workspace}"
  object_lock_enabled = false

  tags = merge(
    {
      Environment = terraform.workspace
    },
    var.tags
  )
}

resource "aws_s3_bucket_ownership_controls" "s3_buckets_ownership" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.s3_buckets[each.key].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.s3_buckets[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFullAccessForAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_buckets[each.key].id}",
          "arn:aws:s3:::${aws_s3_bucket.s3_buckets[each.key].id}/*"
        ]
      },
      {
        Sid    = "AllowLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.s3_buckets[each.key].id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors_configuration" {
  for_each = {
    for key, value in var.buckets : key => value
    if key == "jetolink-frontend-${terraform.workspace}"
  }

  bucket = "${each.key}-${terraform.workspace}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE", "HEAD"]
    allowed_origins = [
      "http://localhost:3000",
      "https://frontend.jetolink.com"
    ]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = var.buckets
  bucket   = "${each.key}-${terraform.workspace}"

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_configuration" {
  for_each = var.buckets
  bucket   = "${each.key}-${terraform.workspace}"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  for_each = var.buckets
  bucket   = "${each.key}-${terraform.workspace}"

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    filter {}
  }
}
