resource "aws_route53_zone" "main" {
  name = var.route53_zone

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    {
      Environment = terraform.workspace
    },
    var.tags
  )
}

resource "aws_acm_certificate" "certificate" {
  validation_method = "DNS"
  domain_name       = var.domain_name

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
  tags = merge(
    {
      Environment = terraform.workspace
    },
    var.tags
  )
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  ttl     = 60
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  zone_id = aws_route53_zone.main.zone_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validate" {
  certificate_arn = aws_acm_certificate.certificate.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

  depends_on = [aws_route53_record.cert_validation]
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [validation_record_fqdns]
  }
}
