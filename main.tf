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

  tags = merge(
    var.tags,
    {
      "Repository" = "https://github.com/kwame-mintah"
    }
  )
}

module "codebuild_python_pytest" {
  source                             = "./modules/codebuild"
  name                               = "${local.name_prefix}-pytest-codebuild"
  service_role_arn                   = module.codepipeline_iam_role.codepipeline_iam_role_arn
  codepipeline_name                  = aws_codepipeline.python_codepipeline.name
  principles_identifiers             = [module.codepipeline_iam_role.codepipeline_iam_role_arn]
  buildspec_yml_file_location        = "./templates/buildspecs/buildspec_python_pytest.yml"
  create_codebuild_test_report_group = true
  codebuild_report_group_name        = "${local.name_prefix}-pytest-codebuild-pytest_reports"
  s3_report_bucket_name              = module.codepipeline_artifact_store.s3_bucket
  s3_report_encryption_key_arn       = module.codepipeline_artifact_store.s3_bucket_kms_key_arn

  tags = merge(
    var.tags
  )
}

module "codepipeline_iam_role" {
  source                             = "./modules/codepipeline-iam-role"
  codestarconnections_connection_arn = aws_codestarconnections_connection.github_kwame_mintah.arn
  ecr_repository_arn                 = ["*", module.lambda_data_preprocessing_ecr.ecr_repository_arn]
  s3_bucket_arn                      = ["${module.codepipeline_artifact_store.s3_bucket_arn}/*", module.codepipeline_artifact_store.s3_bucket_arn]

  tags = merge(
    var.tags
  )
}

module "codepipeline_artifact_store" {
  source                 = "./modules/s3"
  name                   = substr("${local.name_prefix}-codepipeline-store", 0, 63)
  principles_identifiers = [module.codepipeline_iam_role.codepipeline_iam_role_arn]

  tags = merge(
    var.tags
  )
}
