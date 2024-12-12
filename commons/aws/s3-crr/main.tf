terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      configuration_aliases = [aws.primary]
    }
  }
}

# IAM Role Creation for replication
resource "aws_iam_role" "s3_replication_role" {
  name = "${var.name}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_policy" "s3_replica_primary" {

  name        = "${var.name}-s3-replica-primary-to-DR"
  description = "S3 access policy for CRR replication from primary to DR region"
  policy = templatefile("${path.module}/replication.json", {
    source_bucket       = var.primary_bucket_name
    source_kms_key      = var.primary_kms_key
    destination_bucket  = var.secondary_bucket_name
    destination_kms_key = var.secondary_kms_key
  })

}

resource "aws_iam_policy" "s3_replica_secondary" {

  name        = "${var.name}-s3-replica-DR-to-primary"
  description = "S3 access policy for CRR replication from DR to primary region"
  policy = templatefile("${path.module}/replication.json", {
    source_bucket       = var.secondary_bucket_name
    source_kms_key      = var.secondary_kms_key
    destination_bucket  = var.primary_bucket_name
    destination_kms_key = var.primary_kms_key
  })
}

locals {
  replica_policies = {
    primary   = aws_iam_policy.s3_replica_primary.arn
    secondary = aws_iam_policy.s3_replica_secondary.arn
  }
}

resource "aws_iam_role_policy_attachment" "s3_crr_role" {
  for_each = { for k, v in local.replica_policies : k => v }

  role       = aws_iam_role.s3_replication_role.name
  policy_arn = each.value

}

# Primary bucket 
resource "aws_s3_bucket_replication_configuration" "primary" {
  bucket = var.primary_bucket_name

  role = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "${var.name}-primary"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${var.secondary_bucket_name}"
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = var.secondary_kms_key
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  provider = aws.primary

  depends_on = [aws_iam_role_policy_attachment.s3_crr_role]
}

# Secondary bucket

resource "aws_s3_bucket_replication_configuration" "secondary" {
  bucket = var.secondary_bucket_name

  role = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "${var.name}-secondary"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${var.primary_bucket_name}"
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = var.primary_kms_key
      }
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.s3_crr_role]
}