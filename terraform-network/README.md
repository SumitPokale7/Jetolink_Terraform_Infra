# Terraform AWS Network Resource Sharing

This Terraform configuration provisions a Virtual Private Cloud (VPC) and shares selected resources (subnets and security groups) with other AWS accounts using AWS Resource Access Manager (RAM).

---

## 📦 Module Structure

This Terraform setup includes:

- A reusable `network` module that provisions VPC, subnets, and security groups.
- AWS RAM resources for sharing the network infrastructure across accounts.

---

## 📁 Contents

- **data "aws_caller_identity" "this"**  
  Retrieves information about the current AWS account (used to construct ARNs).

- **module "network"**  
  Uses a shared module (`../terraform-modules/network`) to provision the network infrastructure including:
  - VPC
  - Public and private subnets
  - NAT Gateway (optional)
  - Default security group configuration

- **aws_ram_resource_share "network_share"**  
  Creates a RAM resource share with a name based on the current workspace. Sharing is restricted to internal accounts only (`allow_external_principals = false`).

- **aws_ram_principal_association "dev_account"**  
  Associates multiple AWS account numbers (provided in `var.account_numbers`) with the RAM resource share.

- **aws_ram_resource_association**  
  Shares specific VPC resources:
  - **Private Subnets** – Shared across accounts
  - **Public Subnets** – Shared across accounts
  - **Security Group** – Default security group associated with the VPC

---
