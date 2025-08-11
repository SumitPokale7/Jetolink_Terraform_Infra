# Kafka Infrastructure for Jetolink

This Terraform configuration provisions a secure, highly available Apache Kafka cluster using **Amazon Managed Streaming for Kafka (MSK)** tailored for the Jetolink platform.

---

## Overview

### 🔐 KMS Key for Encryption

- Creates a dedicated AWS KMS key to encrypt Kafka data at rest, ensuring compliance and data protection.

### 📚 CloudWatch Log Group

- Provisions a CloudWatch log group to capture broker logs from the MSK cluster.
- Enables centralized monitoring and troubleshooting of Kafka brokers.

### 🖥️ MSK Cluster

- Sets up a fully managed MSK cluster with configurable broker count, Kafka version, and instance types.
- Deploys Kafka brokers into private subnets with appropriate security groups to safeguard the cluster.
- Uses EBS storage for broker data with 1000 GiB volume size per broker.
- Enables encryption at rest using the KMS key and broker logs integration with CloudWatch for enhanced observability.

### 🔑 SSM Parameter Store Integration

- Stores Kafka broker TLS endpoints and Zookeeper connection strings securely in AWS Systems Manager Parameter Store.
- Simplifies service discovery and connectivity for Jetolink services consuming Kafka.

---
