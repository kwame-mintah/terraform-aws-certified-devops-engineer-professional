output "codebuild_project_name" {
  value       = aws_codebuild_project.codebuild_project.name
  description = <<-EOF
    The name of the CodeBuild project created.
    
EOF
}
