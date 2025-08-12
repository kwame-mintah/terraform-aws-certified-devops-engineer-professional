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
    , {
      git_commit           = "83705d064a904fe32af4dc97b8c15922fcc3c167"
      git_file             = "main.tf"
      git_last_modified_at = "2025-04-26 12:31:25"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "github_kwame_mintah"
      yor_trace            = "d0daabff-b8ac-448e-8abf-9394e0b08151"
  })
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
    , {
      git_commit           = "c90adf1e45167135e198bf525c313a5c49cd8aa8"
      git_file             = "main.tf"
      git_last_modified_at = "2025-04-29 20:23:46"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "codebuild_python_pytest"
      yor_trace            = "173b2a35-d4e9-4f49-a872-d6e037010e68"
  })
}

module "codepipeline_iam_role" {
  source                             = "./modules/codepipeline-iam-role"
  codestarconnections_connection_arn = aws_codestarconnections_connection.github_kwame_mintah.arn
  ecr_repository_arn                 = ["*", module.aws_fastapi_lambda_api_gateway_ecr.ecr_repository_arn]
  s3_bucket_arn                      = ["${module.codepipeline_artifact_store.s3_bucket_arn}/*", module.codepipeline_artifact_store.s3_bucket_arn]
  cloudformation_iam_role_arn        = [aws_iam_role.cloudformation_provider_role.arn]

  tags = merge(
    var.tags
    , {
      git_commit           = "a1f01319e189b202496f5133d42ed96c18c4ed44"
      git_file             = "main.tf"
      git_last_modified_at = "2025-05-24 17:02:05"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "codepipeline_iam_role"
      yor_trace            = "58a8de86-53d4-4cf1-9bdc-3c7dd774cd3d"
  })
}

module "codepipeline_artifact_store" {
  source                 = "./modules/s3"
  name                   = substr("${local.name_prefix}-codepipeline-store", 0, 63)
  principles_identifiers = [module.codepipeline_iam_role.codepipeline_iam_role_arn]

  tags = merge(
    var.tags
    , {
      git_commit           = "0fd2d507189db5a065826f3cfe3fb14d0b49a341"
      git_file             = "main.tf"
      git_last_modified_at = "2025-04-26 15:32:56"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "codepipeline_artifact_store"
      yor_trace            = "b475483a-1018-48ad-83b7-3de7b01f9a9a"
  })
}
