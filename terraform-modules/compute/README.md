# Application Load Balancer Infrastructure for Jetolink

This Terraform configuration provisions an **Application Load Balancer (ALB)** and sets up routing for multiple ECS-based services in the Jetolink platform. It includes both HTTP and HTTPS listeners, path-based routing rules, and DNS records for clean service access.

## Overview

### Key Components

- **ALB Module**
  - Creates an ALB with target groups for each ECS service.
  - Health checks are configured per service for robust traffic routing.

- **Listeners**
  - **HTTPS (Port 443)** and **HTTP (Port 80)** listeners are created.
  - Default forwarding is configured for the `jetolink-frontend` service.
  
- **Listener Rules**
  - Host-based routing for `frontend.jetolink.com`.
  - Path-based routing for other services like `/chat-service/*`, `/backend/*`, etc.

- **SSM Parameter Store Integration**
  - Automatically stores service endpoint URLs (based on ALB DNS) into SSM Parameters.
  - Allows frontend and other services to dynamically read endpoint values for communication.

- **Route53 DNS Setup**
  - Creates an `A` record for `frontend.jetolink.com` pointing to the ALB using an alias record.
  - Enables clean and secure access to the frontend service.

---
