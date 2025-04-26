output "s3_bucket_arn" {
  value       = aws_s3_bucket.s3_bucket.arn
  description = <<-EOF
    ARN of the bucket.

EOF
}

output "s3_bucket" {
  value       = aws_s3_bucket.s3_bucket.bucket
  description = <<-EOF
    The bucket.

EOF
}

output "s3_bucket_id" {
  value       = aws_s3_bucket.s3_bucket.id
  description = <<-EOF
    Name of the bucket.

EOF
}

output "s3_bucket_kms_key_arn" {
  value       = aws_kms_key.kms.arn
  description = <<-EOF
    The KMS key ARN.

EOF
}
