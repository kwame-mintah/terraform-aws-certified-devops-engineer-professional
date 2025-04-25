# The Availability Zones data source allows access to the list of AWS Availability Zones 
# which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available_zones" {}

# Data source to get the access to the effective Account ID, User ID, and ARN 
# in which Terraform is authorized.
data "aws_caller_identity" "current_caller_identity" {}

locals {
  name_prefix = "${var.project_name}-${var.aws_region}-${var.env_prefix}"
}

# GitHub CodeStar Connection 
# Authentication with the connection provider must be completed in the AWS Console.
# https://console.aws.amazon.com/codesuite/settings/connections
# AWS Connector for GitHub
# https://github.com/apps/aws-connector-for-github
resource "aws_codestarconnections_connection" "github_kwame_mintah" {
  name          = substr("${local.name_prefix}-github", 0, 32)
  provider_type = "GitHub"

  tags = {
    "Repository" = "https://github.com/kwame-mintah"
  }
}
