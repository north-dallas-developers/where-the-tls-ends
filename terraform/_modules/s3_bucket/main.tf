data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  tags   = merge(var.default_tags, { Name = var.bucket })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = var.bucket
  rule {
    bucket_key_enabled = (var.kms_master_key_id == null || var.use_s3_kms == true) ? false : true
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.use_s3_kms ? data.aws_kms_alias.s3.arn : var.kms_master_key_id
      sse_algorithm     = (var.kms_master_key_id != null || var.use_s3_kms) ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = var.bucket
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  count  = var.policy == null ? 0 : 1
  bucket = aws_s3_bucket.bucket.id
  policy = var.policy
}
