output "bucket_arns" {
  #   value = {for k, v in aws_s3_bucket.s3_buckets: k => v.arn}
  value = values(aws_s3_bucket.s3_buckets)[*].arn
}