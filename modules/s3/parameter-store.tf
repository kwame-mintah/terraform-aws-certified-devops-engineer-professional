resource "aws_ssm_parameter" "s3_bucket_arn" {
  count  = var.store_bucket_arn_in_ssm_parameter ? 1 : 0
  name   = "${var.name}-arn"
  type   = "SecureString"
  value  = aws_s3_bucket.s3_bucket.arn
  key_id = aws_kms_key.kms.id

  tags = merge(
    local.common_tags
  )
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  count  = var.store_bucket_name_in_ssm_parameter ? 1 : 0
  name   = var.name
  type   = "SecureString"
  value  = aws_s3_bucket.s3_bucket.id
  key_id = aws_kms_key.kms.id

  tags = merge(
    local.common_tags
  )
}

resource "aws_ssm_parameter" "s3_kms_key_arn" {
  count  = var.store_kms_key_arn_in_ssm_parameter ? 1 : 0
  name   = "${var.name}-kms-key-arn"
  type   = "SecureString"
  value  = aws_kms_key.kms.arn
  key_id = aws_kms_key.kms.id

  tags = merge(
    local.common_tags
  )
}
