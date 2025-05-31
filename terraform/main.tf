resource "aws_kms_key" "ami_key" {
  description             = "KMS key to share AMIs with Organization"
  enable_key_rotation     = true
  deletion_window_in_days = 20

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "kms-permissions-to-share-ami-with-org"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow use of key by AWS Org",
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = var.org_id
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "ami_key" {
  name          = "alias/ami_kms_key"
  target_key_id = aws_kms_key.ami_key.key_id
}
