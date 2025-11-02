#---------------------------------------------------
# CloudFormation Stack Deployments
#---------------------------------------------------
data "http" "km_dynamodb_template" {
  request_headers = {
    Accept = "text/yaml"
  }
  url = "https://raw.githubusercontent.com/kwame-mintah/aws-cloudformation-playground/b9be84ae1e6ee39d3ed5f45419e2f892ef2d2729/dynamodb-terraform-deployment-template.yaml"
}

resource "aws_cloudformation_stack" "dynamodb_table_stack" {
  name               = "${local.name_prefix}-dynamodb-table-stack"
  timeout_in_minutes = 10

  parameters = {
    DynamoDBTableName = "${local.name_prefix}-dynamodb-table"
  }
  template_body = data.http.km_dynamodb_template.response_body
  # template_body = tostring(yamldecode(data.http.km_dynamodb_template.response_body))

  tags = merge(
    var.tags
    , {
      git_commit           = "a41e271d4cd1ad02a33a66c047b4241304cf0e69"
      git_file             = "cloudformation.tf"
      git_last_modified_at = "2025-04-30 21:19:26"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "dynamodb_table_stack"
      yor_trace            = "61ad9e64-d68c-4b31-a2ce-5d48ca47f1c8"
  })
}


#---------------------------------------------------
# CloudFormation IAM Role for CodePipeline
#---------------------------------------------------
resource "aws_iam_role" "cloudformation_provider_role" {
  name        = "CloudFormationProviderRole"
  description = "Role for CloudFormation provider in CodePipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudformation.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags
    , {
      git_commit           = "9c48a7c10d3c3e5f69e46b5043fd6fb4650c0fa5"
      git_file             = "cloudformation.tf"
      git_last_modified_at = "2025-05-24 16:57:16"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "cloudformation_provider_role"
      yor_trace            = "cdccbf14-ef41-4b4b-9820-7fb51aef8f00"
  })
}

# Create inline policies for the role
resource "aws_iam_role_policy" "cloudformation_provider_policy" {
  name = "CloudFormationProviderPolicy"
  role = aws_iam_role.cloudformation_provider_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "apigateway:DELETE",
          "apigateway:GET",
          "apigateway:PATCH",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:TagResource",
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStacks",
          "cloudformation:GetStackPolicy",
          "cloudformation:GetTemplate",
          "cloudformation:UpdateStack",
          "cloudformation:ValidateTemplate",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:TagRole",
          "lambda:AddPermission",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunction",
          "lambda:PublishVersion",
          "lambda:RemovePermission",
          "lambda:TagResource",
          "lambda:UpdateFunctionCode",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:cloudformation:*:aws:transform/Serverless-*",
          "arn:aws:ecr:*:${data.aws_caller_identity.current_caller_identity.account_id}:repository/devops-engineer-*",
          "arn:aws:iam::${data.aws_caller_identity.current_caller_identity.account_id}:role/*",
          "arn:aws:lambda:*:${data.aws_caller_identity.current_caller_identity.account_id}:function:*",
          "arn:aws:cloudformation:*:${data.aws_caller_identity.current_caller_identity.account_id}:stack/*",
          "arn:aws:iam::${data.aws_caller_identity.current_caller_identity.account_id}:role/${local.name_prefix}*",
          "arn:aws:apigateway:*::/tags/*",
          "arn:aws:apigateway:*::/apis*"
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          module.codepipeline_artifact_store.s3_bucket_arn,
          "${module.codepipeline_artifact_store.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}
