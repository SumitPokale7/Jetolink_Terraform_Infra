# Redis Infrastructure for Jetolink

This Terraform configuration provisions a secure, scalable, and highly available Redis cluster using **Amazon ElastiCache**. It is designed to serve as a fast, in-memory data store or cache layer for Jetolink microservices.

---

## Overview

### 🧠 ElastiCache Redis Cluster

- **Highly Available Setup:**
  - Deploys a Redis replication group with support for Multi-AZ, failover, and encryption (both in transit and at rest).
  - Supports horizontal scaling with configurable node groups and replicas.

- **Subnet Group:**
  - Defines which private subnets the Redis cluster is deployed in for improved security and isolation.
  - Ensures Redis instances are not exposed to the public internet.

- **Parameter Group:**
  - Configures Redis with a custom `maxmemory-policy` (`allkeys-lru`) to evict the least recently used keys when memory is full.
  - Enables precise control over Redis behavior across environments.

- **Security & Encryption:**
  - Uses a designated security group to control access.
  - Enables both in-transit and at-rest encryption for secure data handling.
  - Supports AWS KMS encryption keys if needed.

---
