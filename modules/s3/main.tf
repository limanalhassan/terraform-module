locals {
  env = "dev"
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
  lower   = false
  numeric = true
}

resource "aws_s3_bucket" "dev_bucket" {
  bucket = "${local.env}-bucket-testing-${random_string.random.result}"

  tags = {
    Name        = "${local.env}-bucket"
    Environment = "${local.env}"
  }
}

resource "aws_s3_bucket_ownership_controls" "dev" {
  bucket = aws_s3_bucket.dev_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "dev_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.dev]

  bucket = aws_s3_bucket.dev_bucket.id
  acl    = "private"
}