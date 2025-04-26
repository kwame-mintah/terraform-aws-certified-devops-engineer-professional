variable "codestarconnections_connection_arn" {
  description = <<-EOF
    The connection ARN that is configured and authenticated for the source provider.
    
EOF

  type = string
}

variable "ecr_repository_arn" {
  description = <<-EOF
    The Elastic Container Registry (ECR) that the IAM role will be uploading docker images to.
    
EOF

  type    = list(string)
  default = []
}

variable "s3_bucket_arn" {
  description = <<-EOF
    The S3 Bucket(s) ARN that the IAM role will be uploading to.
    
EOF

  type    = list(string)
  default = []
}

variable "tags" {
  description = <<-EOF
    Tags to be added to resources created.
    
EOF

  type    = map(string)
  default = {}
}