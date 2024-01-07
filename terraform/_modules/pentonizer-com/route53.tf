resource "aws_acm_certificate" "this" {
  domain_name       = local.root
  validation_method = "DNS"
  tags              = merge(var.default_tags, { Name = local.root })
  lifecycle {
    create_before_destroy = true
  }
  subject_alternative_names = [
    local.www-root,
    local.api-root,
    ]
}

resource "aws_route53_zone" "this" {
  name    = local.root
  comment = local.root
  tags    = merge(var.default_tags, { Name = local.root })
}

resource "aws_route53_record" "a" {
  for_each = {
    root = { name = local.root, distribution = aws_cloudfront_distribution.root }
    www  = { name = local.www-root, distribution = aws_cloudfront_distribution.www }
  }
  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = "A"

  alias {
    name                   = each.value.distribution.domain_name
    zone_id                = each.value.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "certificate" {
  for_each = {
    for v in aws_acm_certificate.this.domain_validation_options : v.domain_name => {
      name   = v.resource_record_name
      type   = v.resource_record_type
      record = v.resource_record_value
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id
  depends_on      = [aws_acm_certificate.this, ]
}
