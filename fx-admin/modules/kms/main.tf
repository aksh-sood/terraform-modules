resource "aws_kms_key" "this" {
  description         = "Key used for SSE"
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}-resources"
  target_key_id = aws_kms_key.this.key_id
}


resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    Id = "KMS_Policy"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = var.aws_account
        }

        Resource = "*"
        Sid      = "Enable Everyone KMS Admin Permissions"
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:ListRetirableGrants",
          "kms:Encrypt",
          "kms:RevokeGrant",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey",
          "kms:RetireGrant",
          "kms:CreateGrant",
          "kms:ListGrants"
        ]
        Effect = "Allow"
        Principal = {
          AWS = var.resources_key_user_arns
        }

        Resource = "*"
        Sid      = "Enable Required KMS Usage Permissions"
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:ListRetirableGrants",
          "kms:Encrypt",
          "kms:RevokeGrant",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey",
          "kms:RetireGrant",
          "kms:CreateGrant",
          "kms:ListGrants"
        ]
        Effect = "Allow"
        Principal = {
          AWS = ["*"]
        }

        Resource = "*"
        Sid      = "Enable Required KMS Usage Permissions"
      }
    ]
    Version = "2012-10-17"
  })
}
