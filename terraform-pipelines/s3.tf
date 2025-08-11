resource "aws_s3_bucket" "s3_buckets" {
  object_lock_enabled = false
  for_each            = var.apps
  tags                = var.tags
  bucket              = "${each.value.bucket_name}-artifacts-${terraform.workspace}"
  force_destroy       = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = var.apps
  bucket   = aws_s3_bucket.s3_buckets[each.key].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_configuration" {
  for_each = var.apps
  bucket   = aws_s3_bucket.s3_buckets[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3Public_artifacts" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  for_each                = var.apps
  bucket                  = aws_s3_bucket.s3_buckets[each.key].id
}
