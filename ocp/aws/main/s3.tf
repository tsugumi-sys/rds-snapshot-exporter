locals {
  lifecycle = {
    status          = var.s3.lifecycle.status
    expiration_days = var.s3.lifecycle.expiration_days
  }
}


resource "aws_s3_bucket" "snapshot_bucket" {
  bucket = "${var.project_name}-rds-snapshot3"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.snapshot_bucket.id

  rule {
    id     = "expiration"
    status = local.lifecycle.status
    expiration {
      days = local.lifecycle.expiration_days # NOTE: Enable only for staging
    }
  }
}

resource "aws_s3_bucket_public_access_block" "manage_access" {
  bucket = aws_s3_bucket.snapshot_bucket.id

  block_public_acls = true
  # NOTE: Change to false after policy has changed.
  block_public_policy     = false #tfsec:ignore:aws-s3-block-public-policy
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.snapshot_bucket.id
  acl    = "private"
}
