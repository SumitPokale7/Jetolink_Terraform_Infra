output "hosted_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "acm_certificate" {
  value = aws_acm_certificate.certificate.arn
}

output "postgres_encryption_key_arn" {
  value = aws_kms_key.postgres_encryption_key.arn
}

output "ssm_encryption_key_arn" {
  value = aws_kms_key.ssm_key.arn
}

output "db_secret_arn" {
  value       = aws_secretsmanager_secret.db_secret.arn
  description = "ARN of the DB secret"
}

output "db_secret_username" {
  sensitive   = true
  description = "Username stored in Secrets Manager"
  value       = jsondecode(aws_secretsmanager_secret_version.db_secret_value.secret_string)["username"]
}

output "db_secret_password" {
  sensitive   = true
  description = "Password stored in Secrets Manager"
  value       = jsondecode(aws_secretsmanager_secret_version.db_secret_value.secret_string)["password"]
}
