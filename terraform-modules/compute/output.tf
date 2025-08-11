output "target_group_arns" {
  value = zipmap(
    [for name in keys(var.ecs_services) : "${name}-${terraform.workspace}"],
    module.alb.target_group_arns
  )
}

output "target_group_arn_suffixes" {
  value = zipmap(
    [for name in keys(var.ecs_services) : "${name}-${terraform.workspace}"],
    module.alb.target_group_arn_suffixes
  )
}

output "alb_http_listeners" {
  value = aws_lb_listener.http_listener.arn
}

output "alb_https_listeners" {
  value = aws_lb_listener.https_listener.arn
}

output "alb_arn" {
  value = module.alb.lb_arn
}

output "alb_sg" {
  value = aws_security_group.allow_traffic.id
}

output "alb_dns" {
  value = module.alb.lb_dns_name
}

output "lb_arn_suffix" {
  value = module.alb.lb_arn_suffix
}

output "alb_name" {
  value = split("/", module.alb.lb_arn_suffix)[1]
}
