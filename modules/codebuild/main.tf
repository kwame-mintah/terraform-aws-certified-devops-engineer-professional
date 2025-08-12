# CodeBuild Project -----------------------------
# -----------------------------------------------

locals {
  common_tags = merge(
    var.tags
  )
}

data "aws_caller_identity" "current_caller_identity" {}

resource "aws_codebuild_project" "codebuild_project" {
  name           = var.name
  description    = "CodeBuild managed by Terraform for CodePipeline: ${var.codepipeline_name}"
  service_role   = var.service_role_arn
  encryption_key = aws_kms_key.kms.arn
  build_timeout  = var.build_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.environment_compute_type
    image                       = var.environment_docker_image
    type                        = var.environment_type
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec_yml_file_location)
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = var.codepipeline_name
    }
  }

  tags = merge(
    local.common_tags,
    {
      git_commit           = "64bb78b2e54b43e194e06237b25aec428eb328bf"
      git_file             = "modules/codebuild/main.tf"
      git_last_modified_at = "2025-04-27 18:07:49"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "codebuild_project"
      yor_trace            = "72c20b27-d920-4d59-948d-d117fc0e390e"
  })
}

#---------------------------------------------------
# CodeBuild Test Report Group(s)
#---------------------------------------------------
resource "aws_codebuild_report_group" "codebuild_test_report_group" {
  count = var.create_codebuild_test_report_group ? 1 : 0
  # name = "${var.name}-${regex("buildspec_(.*)\\..*", var.buildspec_yml_file_location)[0]}_reports"
  # Naming can be automatically generated or you can determine how it will be named.
  # https://docs.aws.amazon.com/codebuild/latest/userguide/test-report-group-naming.html
  name = var.codebuild_report_group_name
  type = "TEST"

  export_config {
    type = "S3"

    s3_destination {
      bucket              = var.s3_report_bucket_name
      encryption_disabled = false
      encryption_key      = var.s3_report_encryption_key_arn
      packaging           = "NONE"
      path                = "/"
    }
  }

  tags = merge(
    local.common_tags,
    {
      git_commit           = "78e61acb41eaf7ee24c8f872d85815c0d0a5f4f0"
      git_file             = "modules/codebuild/main.tf"
      git_last_modified_at = "2025-04-27 20:23:32"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "codebuild_test_report_group"
      yor_trace            = "631474f6-27ef-4113-bf68-1a133f3f1e1f"
  })
}

#---------------------------------------------------
# Key Management Service
#---------------------------------------------------

resource "aws_kms_key" "kms" {
  description             = "Encrypt S3 Bucket data stored."
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(
    local.common_tags
    , {
      git_commit           = "64bb78b2e54b43e194e06237b25aec428eb328bf"
      git_file             = "modules/codebuild/main.tf"
      git_last_modified_at = "2025-04-27 18:07:49"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "kms"
      yor_trace            = "83ea292d-1999-40db-95f2-b48869a185eb"
  })
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.name}-kms-key"
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
