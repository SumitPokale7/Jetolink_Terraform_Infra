resource "aws_route53_record" "frontend_record" {
  type    = "A"
  zone_id = var.hosted_zone_id
  name    = "frontend.jetolink.com"

  alias {
    evaluate_target_health = true
    zone_id                = module.alb.lb_zone_id
    name                   = module.alb.lb_dns_name
  }
}
