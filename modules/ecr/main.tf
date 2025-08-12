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
    , {
      git_commit           = "b9017037e8c98ea5c10decac915560719cfc9431"
      git_file             = "modules/ecr/main.tf"
      git_last_modified_at = "2025-04-26 12:25:33"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "repository"
      yor_trace            = "838019fe-a7c4-4c7e-acf1-d2e9b6fd3167"
  })
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
    , {
      git_commit           = "b9017037e8c98ea5c10decac915560719cfc9431"
      git_file             = "modules/ecr/main.tf"
      git_last_modified_at = "2025-04-26 12:25:33"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "kms"
      yor_trace            = "557fb67c-7d04-4779-bd4a-cfd3df18897a"
  })
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
