data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "firehose_role" {
  name = "FX_firehose_delivery_role_${var.name}_${var.region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "firehose_policy" {
  name = "FX-firehose-policy_${var.name}_${var.region}"

  policy = templatefile("${path.module}/templates/firehose.json", {
    region     = var.region,
    account_id = data.aws_caller_identity.current.account_id
  })
}

resource "aws_iam_role_policy_attachment" "firehose_role" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

# FIREHOSE

resource "aws_kinesis_firehose_delivery_stream" "trm_delivery_firehose_stream" {
  name        = "trml-delivery-s3-${var.name}"
  destination = "extended_s3"
  tags        = var.tags

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.bucket_arn
  }

  server_side_encryption {
    enabled  = false
    # key_type = "CUSTOMER_MANAGED_CMK"
    # key_arn  = var.kms_key_arn
  }
}

#TODO: Add SSE
resource "aws_kinesis_firehose_delivery_stream" "failed_trml_firehose_stream" {
  name        = "failed-trml-delivery-s3-${var.name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.bucket_arn
  }

  server_side_encryption {
    enabled  = false
    # key_type = "CUSTOMER_MANAGED_CMK"
    # key_arn  = var.kms_key_arn
  }
}

