# S3 Bucket Management for Jetolink

This Terraform configuration manages the creation, security, and lifecycle of S3 buckets for the Jetolink platform. It includes bucket policies, versioning, encryption, and lifecycle management, ensuring that all buckets are configured securely and optimized for storage.

---

## Overview

### 📦 S3 Bucket Creation

- **Dynamic Bucket Creation:** Buckets are created dynamically based on the configuration in `var.buckets`, allowing you to define a flexible and reusable S3 configuration across multiple environments (e.g., dev, prod).
- **Bucket Naming:** Each bucket's name is prefixed with the workspace name to ensure uniqueness across environments.
- **Object Locking:** Disabled by default, but can be enabled based on future requirements.

### 🛡️ Bucket Ownership & Policies

- **Ownership Controls:** Enforces bucket ownership rules to ensure the bucket owner has full control over all objects within the bucket.
- **Bucket Policy:** 
  - Grants full access to the AWS account that owns the Terraform workspace.
  - Configures S3 bucket access for log delivery services (`logging.s3.amazonaws.com`) with specific ACL requirements for log delivery.

### 🔐 Server-Side Encryption & Versioning

- **Encryption at Rest:** All buckets are configured with server-side encryption using AES-256, ensuring that all objects are encrypted by default.
- **Versioning:** Enabled by default for all buckets to retain previous object versions, preventing accidental data loss.

### 🔄 Lifecycle Configuration

- **Lifecycle Rules:** Automatically deletes old object versions after 90 days to optimize storage costs. This rule ensures that noncurrent object versions are cleaned up after a specified retention period.

### 🌐 Cross-Origin Resource Sharing (CORS)

- **Frontend Bucket CORS Configuration:** A CORS configuration is applied specifically for the frontend bucket (`jetolink-frontend-${terraform.workspace}`), allowing cross-origin requests from the Jetolink frontend (hosted on `frontend.jetolink.com`).

---
