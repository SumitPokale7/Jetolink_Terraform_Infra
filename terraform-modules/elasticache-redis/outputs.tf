output "redis_endpoint" {
  description = "The primary endpoint for the Redis cluster"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}
