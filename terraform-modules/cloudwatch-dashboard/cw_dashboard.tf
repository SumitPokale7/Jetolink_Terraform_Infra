resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [

      # ECS Logs (Table View)
      {
        type   = "log",
        x      = 0,
        y      = 0,
        width  = 24,
        height = 6,
        properties = {
          query  = "SOURCE '/ecs/${var.ecs_service_name}' | fields @timestamp, @message | sort @timestamp desc | limit 20",
          region = var.region,
          title  = "ECS Logs - ${var.ecs_service_name}"
        }
      },

      # ALB RequestCount Pie Chart (Traffic Split)
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "TargetGroup", "tg-${var.ecs_service_name}", "LoadBalancer", var.alb_id]
          ],
          period = 300,
          stat   = "Sum",
          view   = "pie",
          region = var.region,
          title  = "ALB Request Count - ${var.ecs_service_name}"
        }
      },

      # ECS CPU & Memory (Bar Chart)
      {
        type   = "metric",
        x      = 12,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ],
          view    = "bar",
          stacked = false,
          region  = var.region,
          title   = "ECS CPU & Memory - ${var.ecs_service_name}",
          period  = 300,
          stat    = "Average"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "frontend_503_alarm" {
  alarm_name          = "jetolink-frontend-${terraform.workspace}-alb-503-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count" # note: this metric catches ALB-level 5XX like misrouting
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers if ALB returns 5XX (like 503) errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_id
  }

  alarm_actions = [aws_sns_topic.frontend_503_alarm_topic.arn]
}

resource "aws_sns_topic" "frontend_503_alarm_topic" {
  name = "frontend-503-alarm-topic-${terraform.workspace}"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.frontend_503_alarm_topic.arn
  protocol  = "email"
  endpoint  = "sanketshirode1994@gmail.com"
}
