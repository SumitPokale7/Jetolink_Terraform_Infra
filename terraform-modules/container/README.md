# Jetolink ECS, ECR, and IAM Infrastructure

This Terraform configuration provisions the containerized infrastructure for Jetolink microservices using Amazon ECS with Fargate, Amazon ECR for container storage, and IAM roles for secure access to AWS resources.

---

## Overview

### 🚀 ECS (Elastic Container Service)

- **ECS Cluster:** Creates a dedicated ECS cluster per environment (workspace) with Container Insights enabled for monitoring.
- **Capacity Providers:** Configures support for both `FARGATE` and `FARGATE_SPOT` to allow flexible cost optimization.
- **Task Definitions:** Generates ECS task definitions for each microservice, defining CPU, memory, container images, environment variables, secrets, and health checks.
- **ECS Services:** Deploys ECS services with networking (subnets, security groups) and links them to load balancer target groups for traffic management.
- **CloudWatch Logs:** Creates a unique log group per ECS service, enabling centralized log collection and 7-day retention.

---

### 📦 ECR (Elastic Container Registry)

- **Repositories:** Creates an ECR repository for each Jetolink service, organized per environment.
- **Security & Scanning:** Enables encryption at rest and optional vulnerability scanning on image push.
- **Tag Mutability:** Allows mutable image tags for flexibility during development and deployment.

---

### 🔐 IAM (Identity & Access Management)

- **Task Role:**
  - A custom IAM role assigned to containers at runtime.
  - Grants services only the permissions they need (e.g., access to S3, DynamoDB, etc.).
- **Execution Role:**
  - Grants ECS permissions to pull images from ECR, read from Secrets Manager and SSM, and write logs to CloudWatch.
  - Includes AWS-managed and custom policies tailored to ECS needs.

---
