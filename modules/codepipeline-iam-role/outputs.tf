output "codepipeline_iam_role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = <<-EOF
    Full ARN of the Codepipeline IAM Role.
    
EOF
}
