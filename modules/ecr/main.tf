# Elastic Container Registry  -------------------
# -----------------------------------------------

locals {
  common_tags = merge(
    var.tags,
  )
}

data "aws_caller_identity" "current_caller_identity" {}

#------------------------------------------------
# Repository
#------------------------------------------------
resource "aws_ecr_repository" "repository" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.kms.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags
  )
}

#---------------------------------------------------
# Key Management Service
#---------------------------------------------------
resource "aws_kms_key" "kms" {
  description             = "Encrypt ECR repositories"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    local.common_tags
  )
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.repository_name}-kms-key"
  target_key_id = aws_kms_key.kms.key_id
}

resource "aws_kms_key_policy" "kms_key_policy" {
  key_id = aws_kms_key.kms.key_id
  policy = data.aws_iam_policy_document.kms_policy.json
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:root account needs access to resolve error, the new key policy will not allow you to update the key policy in the future.
    #checkov:skip=CKV_AWS_111:root account needs access to resolve error, the new key policy will not allow you to update the key policy in the future.
    #checkov:skip=CKV_AWS_109:root account needs access to resolve error, the new key policy will not allow you to update the key policy in the future.
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current_caller_identity.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    principals {
      type        = "AWS"
      identifiers = var.principles_identifiers
    }
    resources = [
      aws_kms_key.kms.arn,
    ]
  }
}
