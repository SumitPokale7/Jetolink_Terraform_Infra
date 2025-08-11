# CloudWatch Dashboard for ECS and ALB Monitoring

This Terraform configuration creates a custom AWS CloudWatch Dashboard that provides insights into ECS service logs, ALB traffic, and ECS resource utilization.

## Features

The dashboard includes the following widgets:

1. **ECS Logs Table**
   - **Description:** Displays the most recent 20 log entries for a specified ECS service.
   - **Log Source:** `/ecs/${var.ecs_service_name}`
   - **Fields:** `@timestamp`, `@message`
   - **Sort Order:** Descending by timestamp

2. **ALB Request Count Pie Chart**
   - **Description:** Shows a pie chart representing the distribution of requests to the Application Load Balancer (ALB) target group.
   - **Metric Namespace:** `AWS/ApplicationELB`
   - **Metric Name:** `RequestCount`
   - **Filters:** Target Group and Load Balancer ID
   - **Stat:** Sum over a 5-minute period

3. **ECS CPU & Memory Utilization (Bar Chart)**
   - **Description:** Displays CPU and memory usage for the ECS service in a bar chart format.
   - **Metric Namespace:** `AWS/ECS`
   - **Metric Names:** `CPUUtilization`, `MemoryUtilization`
   - **Filters:** ECS service name and ECS cluster name
   - **Stat:** Average over a 5-minute period
