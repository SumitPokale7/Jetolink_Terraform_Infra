# Creates a subnet group for Redis to define which subnets the cluster nodes will be deployed in
resource "aws_elasticache_subnet_group" "this" {
  tags       = var.tags
  subnet_ids = var.private_subnets
  name       = "jetolink-elasticache-redis-${terraform.workspace}"
}

# Defines a custom parameter group for Redis with a specific eviction policy
resource "aws_elasticache_parameter_group" "redis" {
  family      = var.family # e.g., "redis7"
  description = "Parameter group for Redis ${terraform.workspace}"
  name        = "jetolink-redis-parameter-group-${terraform.workspace}"

  parameter {
    value = "allkeys-lru" # Defines eviction policy: evict least recently used keys
    name  = "maxmemory-policy"
  }

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "Redis-parameter-group-${terraform.workspace}"
    },
    var.tags
  )
}

# Provisions a highly available and secure Redis cluster with encryption and failover support
resource "aws_elasticache_replication_group" "redis" {
  port                       = var.redis_port
  engine                     = var.redis_engine   # "redis"
  engine_version             = var.engine_version # e.g., "7.0"
  num_node_groups            = var.num_node_groups
  multi_az_enabled           = var.multi_az_enabled
  node_type                  = var.redis_instance_type
  replicas_per_node_group    = var.replicas_per_node_group
  security_group_ids         = var.default_security_group_id # Control access
  automatic_failover_enabled = var.automatic_failover_enabled
  transit_encryption_enabled = var.transit_encryption_enabled # Encrypts data in transit
  at_rest_encryption_enabled = var.at_rest_encryption_enabled # Encrypts data at rest
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  replication_group_id       = "jetolink-redis-replication-${terraform.workspace}"
  description                = "Redis replication group for ${terraform.workspace}"

  tags = merge(
    {
      Environment = terraform.workspace,
      Name        = "Redis-${terraform.workspace}"
    },
    var.tags
  )
  depends_on = [aws_elasticache_subnet_group.this]
}
