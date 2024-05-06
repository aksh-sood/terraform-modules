resource "aws_s3_bucket" "this" {
  bucket = var.name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-bucket" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"

    }
  }

}


