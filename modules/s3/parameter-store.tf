resource "aws_ssm_parameter" "s3_bucket_arn" {
  count  = var.store_bucket_arn_in_ssm_parameter ? 1 : 0
  name   = "${var.name}-arn"
  type   = "SecureString"
  value  = aws_s3_bucket.s3_bucket.arn
  key_id = aws_kms_key.kms.id

  tags = merge(
    local.common_tags
    , {
      git_commit           = "e52e8053479152967ad014e6382a688336c4e0af"
      git_file             = "modules/s3/parameter-store.tf"
      git_last_modified_at = "2025-04-26 15:27:43"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "s3_bucket_arn"
      yor_trace            = "57615924-4a33-426a-9dd3-95ec9b47039a"
  })
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  count  = var.store_bucket_name_in_ssm_parameter ? 1 : 0
  name   = var.name
  type   = "SecureString"
  value  = aws_s3_bucket.s3_bucket.id
  key_id = aws_kms_key.kms.id

  tags = merge(
    local.common_tags
    , {
      git_commit           = "e52e8053479152967ad014e6382a688336c4e0af"
      git_file             = "modules/s3/parameter-store.tf"
      git_last_modified_at = "2025-04-26 15:27:43"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "s3_bucket_name"
      yor_trace            = "ef809aed-7cdf-42cf-91bb-aec8414a067d"
  })
}

resource "aws_ssm_parameter" "s3_kms_key_arn" {
  count  = var.store_kms_key_arn_in_ssm_parameter ? 1 : 0
  name   = "${var.name}-kms-key-arn"
  type   = "SecureString"
  value  = aws_kms_key.kms.arn
  key_id = aws_kms_key.kms.id

  tags = merge(
    local.common_tags
    , {
      git_commit           = "e52e8053479152967ad014e6382a688336c4e0af"
      git_file             = "modules/s3/parameter-store.tf"
      git_last_modified_at = "2025-04-26 15:27:43"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "s3_kms_key_arn"
      yor_trace            = "26f8f2ee-6947-47a6-b712-4cfd3ab81813"
  })
}
