#---------------------------------------------------
# CloudFormation Stack Deployments
#---------------------------------------------------
data "http" "km_dynamodb_template" {
  request_headers = {
    Accept = "text/yaml"
  }
  url = "https://raw.githubusercontent.com/kwame-mintah/aws-cloudformation-playground/e81092ed4e6b27d887ef2dbb489bb8efa59a44f4/dynamodb-terraform-deployment-template.yaml"
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
  )
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
  )
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
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:PassRole",
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
