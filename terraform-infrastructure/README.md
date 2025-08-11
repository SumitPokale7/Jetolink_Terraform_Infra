# Terraform: Application Infrastructure Deployment

This repository provisions a comprehensive AWS infrastructure for deploying containerized services, persistent storage, messaging, and monitoring using modular Terraform configurations.

---

## 🏗️ Modules Overview

This setup leverages multiple Terraform modules to deploy a fully functional environment:

### 🔐 Network (Pre-provisioned via remote state)
Relies on a previously deployed network stack (VPC, subnets, security groups) pulled via `terraform_remote_state`.

---

### 📦 Modules Used

- **S3**  
  Creates and manages S3 buckets for various storage needs.

- **Compute**  
  Provisions an Application Load Balancer (ALB), ECS cluster, and related compute infrastructure.

- **Container**  
  Deploys ECS services using Fargate or EC2, sets up IAM roles, security groups, and ECR repositories.

- **Redis (ElastiCache)**  
  Sets up a Redis cluster with configurable high availability and encryption options.

- **Postgres (Aurora PostgreSQL)**  
  Deploys an Aurora PostgreSQL cluster using secrets from a centralized global resource module.

- **MSK Kafka**  
  Provisions an MSK (Managed Streaming for Kafka) cluster for event streaming.

- **CloudWatch Dashboards**  
  Creates custom CloudWatch dashboards for each ECS service, providing observability across compute resources.

---

## 🔁 Dependencies

- **Remote State**: All modules depend on previously created network and global resources via `terraform_remote_state`.
- **Inter-Module Links**: Many modules (e.g. container, kafka) depend on outputs from compute or redis modules.

---

## ⚙️ Requirements

- Terraform 1.x+
- AWS CLI configured
- Backend and remote state for shared modules (network/global) already initialized

---
