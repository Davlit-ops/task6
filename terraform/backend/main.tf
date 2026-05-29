provider "aws" {
  region  = "us-east-2"
  profile = "task6"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "aws-task6-eks"
}

#KMS  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_kms_key" "terraform_state" {
  description = "KMS key for encrypting terraform state in S3 bucket"
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform-state-bucket-key"
  target_key_id = aws_kms_key.terraform_state.key_id
}

resource "aws_kms_key_policy" "terraform_state" {
  key_id = aws_kms_key.terraform_state.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullAccessForDeployerOnly"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.arn
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

# versioning  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
# encryption   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# lifecycle   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#newer_noncurrent_versions-3
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    id     = "keep3"
    status = "Enabled"
    noncurrent_version_expiration {
      newer_noncurrent_versions = 2
      noncurrent_days           = 1
    }
    expiration {
      expired_object_delete_marker = true
    }
  }
}
