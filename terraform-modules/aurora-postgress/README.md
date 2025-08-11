# 🔐 Terraform: Bastion Host & Aurora PostgreSQL Cluster

This Terraform module provisions a secure Bastion host and an Aurora PostgreSQL cluster, including optional global cluster configuration (for production) and automated database bootstrapping via SSH.

---

## 📦 Overview

### 🖥️ Bastion Host

- Amazon Linux 2 EC2 instance for secure access to private infrastructure (e.g., RDS)
- Automatically installs:
  - PostgreSQL client
  - SOPS (for secrets decryption)
- Generates and registers an SSH key pair
- Includes IAM Role with KMS decrypt permissions
- Uploads:
  - `secrets_<WORKSPACE_NAME>.json` file
  - `bootstrap.sh` script
- Executes the script remotely to bootstrap databases

---

### 🗄️ Aurora PostgreSQL Cluster

- Creates:
  - Subnet group
  - Security group with PostgreSQL ingress
  - Aurora Cluster with HA instances
- **Production-only**: Adds to a global cluster
- Supports snapshot configuration, deletion protection, backup windows

---

## 🛠️ Key Resources

### Bastion

- `aws_instance.bastion` – Public EC2 instance for admin access
- `aws_iam_role.bastion_kms_role` – IAM role with KMS decryption permissions
- `aws_key_pair.bastion_key` – Auto-generated SSH key
- `null_resource.upload_*` – Transfers bootstrap files
- `null_resource.create_databases` – Executes the bootstrap script

### RDS (Aurora PostgreSQL)

- `aws_rds_cluster` – Main Aurora cluster
- `aws_rds_cluster_instance` – HA instances - 2
- `aws_db_subnet_group` – Subnet group using private subnets
- `aws_security_group.rds_sg` – Security group for DB access
- `aws_rds_global_cluster` – Created **only in `prod`**

---

## 🔄 Bootstrapping

The following files must exist in the module directory:

- `secrets_<WORKSPACE_NAME>.json` – Contains database and user secrets

  - To update the database username and password, modify `secrets_<WORKSPACE_NAME>.json` with the new credentials:
 
        Ex. {"username": "test","password": "pass"}

   - To encrypt the updated `secrets_<WORKSPACE_NAME>.json` file using the KMS key ARN for alias `aurora-postgres-encryption-key-<WORKSPACE_NAME>`.

     > This key is generated in `terraform-global-resources`


         Ex: sops --kms "KMS_KEY_ARN" -e -i secrets_<WORKSPACE_NAME>.json

   - To Decrypt the `secrets_<WORKSPACE_NAME>.json` file using sops. Ensure first that AWS CLI is configured with Desired `WORKSPACE`, Use Below Command to decrypt file.


          Ex: sops -d -i secrets_<WORKSPACE_NAME>.json

- `bootstrap.sh` – Shell script that creates initial databases/schemas/etc.
       
   - To create a new database and user or modify an existing one, edit the `bootstrap.sh` script.

Terraform will upload and execute them on the bastion host after RDS provisioning.

---

## ✅ Requirements

- VPC with private and public subnets
- Terraform 1.x+
- SSH access to the bastion from your IP (implicitly assumed)
- Secrets and bootstrap script must be included in the same directory

---
