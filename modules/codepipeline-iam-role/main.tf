# CodePipeline IAM Role  -----------------------
# -----------------------------------------------

locals {
  common_tags = merge(
    var.tags
  )
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

#---------------------------------------------------
# IAM Policies
#---------------------------------------------------

resource "aws_iam_policy" "codepipeline_iam_policies" {
  name   = "codepipeline-starter"
  policy = data.aws_iam_policy_document.codepipeline_policies.json
  path   = "/codepipeline/"

  tags = merge(
    local.common_tags
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
