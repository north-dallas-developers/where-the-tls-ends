resource "aws_cloudfront_distribution" "root" {
  tags = merge(var.default_tags, { Name = local.root })
  origin {
    domain_name              = "${local.root}.s3.${var.region}.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.this["root"].id
    origin_id                = local.root // This can be any name to identify this origin.
  }
  enabled             = true
  default_root_object = "index.htm"
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.root // This needs to match the `origin_id` above.
    min_ttl                = 0
    default_ttl            = 3600 #86400
    max_ttl                = 31536000
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  aliases = [local.root]
  custom_error_response {
    error_caching_min_ttl = 86400
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.htm"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = {
    root = local.root
  }
  name                              = each.value
  description                       = each.value
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4" # server name indication, or how are requests signed between AWS services
}

resource "aws_cloudfront_distribution" "www" {
  tags = merge(var.default_tags, { Name = local.www-root })
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"] # currently does not support 1.3
    }
    domain_name = aws_s3_bucket_website_configuration.www.website_endpoint
    origin_id   = local.www-root
  }

  enabled             = true
  default_root_object = ""

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.www-root
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  aliases = [local.www-root]
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
  }
}
