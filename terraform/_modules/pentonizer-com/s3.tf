# This module is copied to ../s3_bucket in this repository. The Foundry Force repository is not public
module "bucket" {
  for_each     = local.buckets
  source       = "git::git@github.com:foundryforce/terraform-modules.git//aws/s3_bucket"
  bucket       = each.value
  default_tags = var.default_tags
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  for_each = local.buckets
  bucket   = module.bucket[each.key].bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  for_each   = local.buckets
  bucket     = module.bucket[each.key].bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucket]
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = module.bucket["www"].bucket.id
  redirect_all_requests_to {
    host_name = local.root
    protocol  = "https"
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  for_each = {
    root = { bucket = module.bucket["root"].bucket, distribution_arn = aws_cloudfront_distribution.root.arn }
    www  = { bucket = module.bucket["www"].bucket, distribution_arn = aws_cloudfront_distribution.www.arn }
  }
  bucket = each.value.bucket.id
  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "PolicyForCloudFrontPrivateContent",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipal",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "${each.value.bucket.arn}/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "${each.value.distribution_arn}"
        }
      }
    }
  ]
}
EOF
}
