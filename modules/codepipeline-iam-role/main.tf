# CodePipeline IAM Role  -----------------------
# -----------------------------------------------

locals {
  common_tags = merge(
    var.tags
  )
  create_inline_s3_policy  = (length(var.s3_bucket_arn) > 0)
  create_inline_ecr_policy = (length(var.ecr_repository_arn) > 0)
}

data "aws_caller_identity" "current_caller_identity" {}
data "aws_region" "current_caller_region" {}
data "aws_partition" "current_partition" {}

#---------------------------------------------------
# IAM Role
#---------------------------------------------------

resource "aws_iam_role" "codepipeline_role" {
  name               = "AWSCodePipelineRole"
  path               = "/codepipeline/"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json

  tags = merge(
    local.common_tags
  )
}

#---------------------------------------------------
# IAM Policy Attachments
#---------------------------------------------------

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_iam_policies.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment_s3" {
  count      = local.create_inline_s3_policy ? 1 : 0
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_allow_s3[0].arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment_ecr" {
  count      = local.create_inline_ecr_policy ? 1 : 0
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_allow_ecr[0].arn
}


#---------------------------------------------------
# IAM Policies
#---------------------------------------------------

resource "aws_iam_policy" "codepipeline_iam_policies" {
  name   = "codepipeline-starter"
  policy = data.aws_iam_policy_document.codepipeline_policies.json
  path   = "/codepipeline/"

  tags = merge(
    local.common_tags,
  )
}

resource "aws_iam_policy" "codepipeline_allow_ecr" {
  count  = local.create_inline_ecr_policy ? 1 : 0
  name   = "CodePipelineAllowECR"
  policy = data.aws_iam_policy_document.ecr_allow_action_policy_document[0].json

  tags = merge(
    local.common_tags,
  )
}

resource "aws_iam_policy" "codepipeline_allow_s3" {
  count  = local.create_inline_s3_policy ? 1 : 0
  name   = "CodePipelineAllowS3Access"
  policy = data.aws_iam_policy_document.s3_allow_action_policy_document[0].json

  tags = merge(
    local.common_tags,
  )
}

#---------------------------------------------------
# IAM Documents
#---------------------------------------------------

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policies" {
  statement {
    sid       = "CodeConnectionsActionDefaultPolicy"
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestarconnections_connection_arn]
  }

  statement {
    sid    = "CodeBuildActionDefaultPolicy"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:StopBuild"
    ]
    resources = ["arn:aws:codebuild:${data.aws_region.current_caller_region.name}:${data.aws_caller_identity.current_caller_identity.account_id}:project/*"]
  }

  statement {
    sid    = "CodePipelineDefaultPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:${data.aws_partition.current_partition.partition}:logs:${data.aws_region.current_caller_region.name}:${data.aws_caller_identity.current_caller_identity.account_id}:log-group:*"]
  }

  statement {
    sid    = "CodeBuildDefaultPolicy"
    effect = "Allow"
    actions = [
      "codebuild:BatchPutCodeCoverages",
      "codebuild:BatchPutTestCases",
      "codebuild:CreateReport",
      "codebuild:CreateReportGroup",
      "codebuild:UpdateReport"
    ]
    resources = ["arn:aws:codebuild:${data.aws_region.current_caller_region.name}:${data.aws_caller_identity.current_caller_identity.account_id}:project/*"]
  }
}

data "aws_iam_policy_document" "s3_allow_action_policy_document" {
  count = local.create_inline_s3_policy ? 1 : 0
  statement {
    sid = "S3AllowActions"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucketVersions",
      "s3:ListBucket"
    ]
    effect    = "Allow"
    resources = var.s3_bucket_arn
  }
}

data "aws_iam_policy_document" "ecr_allow_action_policy_document" {
  count = local.create_inline_ecr_policy ? 1 : 0
  statement {
    sid = "ECRBuildAndPublishPolicy"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    effect    = "Allow"
    resources = var.ecr_repository_arn
  }
  #checkov:skip=CKV_AWS_356:this is the minimum permissions needed to login and push
}
