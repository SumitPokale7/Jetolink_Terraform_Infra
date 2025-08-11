# VPC Infrastructure for Jetolink

This Terraform configuration sets up the core network infrastructure for the Jetolink platform using the AWS VPC module. It provides a secure, scalable, and highly available networking foundation for all services and environments.

---

## Overview

### 🌐 Virtual Private Cloud (VPC)

- Provisions a VPC with a customizable CIDR block.
- Automatically deploys across multiple Availability Zones for high availability.
- Supports both public and private subnets to isolate services and control access.
- Configurable support for NAT Gateways to allow private subnet instances to access the internet securely.

### 🔐 Security Group

- Creates a central security group to control access within the VPC.
- Ingress rules are dynamically generated based on predefined settings and scoped to the VPC CIDR block.
- Designed for reuse across multiple services like ECS, Redis, Kafka, etc.

### 🏷️ Tagging and Environment Isolation

- All resources are tagged with the environment name (based on Terraform workspace).
- Ensures easy identification, cost tracking, and environment separation (e.g., dev, staging, prod).

---
