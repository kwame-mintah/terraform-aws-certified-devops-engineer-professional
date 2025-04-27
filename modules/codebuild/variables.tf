variable "build_timeout" {
  description = <<-EOF
    Number of minutes, from 5 to 2160 (36 hours), for AWS CodeBuild to 
    wait until timing out any related build that does not get marked as completed.
    
EOF

  type    = number
  default = 10
}

variable "buildspec_yml_file_location" {
  description = <<-EOF
    Local file path to the BuildSpec in a YAML-formatted file.
    
EOF

  type    = string
  default = null
}

variable "codepipeline_name" {
  description = <<-EOF
    The CodePipeline that will be utilising the CodeBuild compute.
    
EOF

  type = string
}

variable "environment_compute_type" {
  description = <<-EOF
     Information about the compute resources the build project will use. 
    
EOF

  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "environment_docker_image" {
  description = <<-EOF
    Docker image to use for this build project. 
    Valid values include [Docker images provided by CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html)
    
EOF

  type    = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "environment_type" {
  description = <<-EOF
    Type of build environment to use for related builds.
    
EOF

  type    = string
  default = "LINUX_CONTAINER"
}

variable "name" {
  description = <<-EOF
    The CodeBuild Project's name.
    
EOF

  type = string
}

variable "service_role_arn" {
  description = <<-EOF
    Amazon Resource Name (ARN) of the AWS Identity and Access Management (IAM)
    role that enables AWS CodeBuild to interact with dependent AWS services on
    behalf of the AWS account.

EOF

  type = string
}

variable "tags" {
  description = <<-EOF
    Tags to be added to resources created.
    
EOF

  type    = map(string)
  default = {}
}

variable "principles_identifiers" {
  description = <<-EOF
    List of ARNs that have access to th KMS key.
    
EOF

  type    = list(string)
  default = []
}
