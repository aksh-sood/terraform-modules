resource "aws_s3_bucket" "s3-bucket" {
  bucket = var.name
  tags   = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-bucket" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"

    }
  }

}


