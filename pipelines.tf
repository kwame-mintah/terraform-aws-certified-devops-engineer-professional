#---------------------------------------------------
# Python Build and Deploy Pipeline
#---------------------------------------------------

resource "aws_codepipeline" "python_codepipeline" {
  name          = "${local.name_prefix}-python-codepipeline"
  pipeline_type = "V2"
  role_arn      = module.codepipeline_iam_role.codepipeline_iam_role_arn

  artifact_store {
    location = module.codepipeline_artifact_store.s3_bucket
    type     = "S3"
    encryption_key {
      id   = module.codepipeline_artifact_store.s3_bucket_kms_key_arn
      type = "KMS"
    }
  }

  # Stage declaration
  # https://docs.aws.amazon.com/codepipeline/latest/userguide/stage-requirements.html
  # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference.html
  stage {
    name = "Source"

    action {
      # Action declaration
      # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-requirements.html
      name             = "Pull_GitHub_Repository"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      # Action output variables
      # https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-variables.html#reference-variables-output-CodeConnections
      namespace = "SourceVariables"

      configuration = {
        # CodeStarSourceConnection for GitHub
        # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html#action-reference-CodestarConnectionSource-config
        ConnectionArn        = aws_codestarconnections_connection.github_kwame_mintah.arn
        FullRepositoryId     = "kwame-mintah/aws-fastapi-lambda-api-gateway"
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP" # CODEBUILD_CLONE_REF
        DetectChanges        = "true"
      }
    }
  }

  stage {
    name = "Test"

    action {
      name            = "Run_Python_Pytest_Unit_Tests"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        # AWS CodeBuild build and test action reference
        # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeBuild.html
        ProjectName      = "${local.name_prefix}-pytest-codebuild" # Unable to reference module due to circular dependency
        BatchEnabled     = "false"
        CombineArtifacts = "false"
      }
    }
  }

  stage {
    name = "Registry"

    # ECRBuildAndPublish build action reference
    # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-ECRBuildAndPublish.html
    # ! This action uses CodePipeline managed CodeBuild compute to run commands in a build environment. 
    # ! Running the commands action will incur separate charges in AWS CodeBuild.
    action {
      name            = "Build_and_Push_to_ECR"
      category        = "Build"
      owner           = "AWS"
      provider        = "ECRBuildAndPublish"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ECRRepositoryName = module.aws_fastapi_lambda_api_gateway_ecr.ecr_repository_name
        DockerFilePath    = "."
        ImageTags         = "#{SourceVariables.CommitId}"
      }
    }
  }

  stage {
    name = "Invoke_CloudFormation_Pipeline"

    action {
      name     = "Deploy_CloudFormation_Template"
      category = "Invoke"
      owner    = "AWS"
      provider = "CodePipeline"
      version  = "1"

      configuration = {
        PipelineName = aws_codepipeline.cloudformation_template_codepipeline.name
        Variables = jsonencode([
          {
            name  = "ActionMode"
            value = "CREATE_UPDATE"
          },
          {
            name  = "StackName"
            value = "${var.project_name}-lambda-api-gateway-stack"
          },
          {
            name  = "TemplatePath"
            value = "lambda-api-gateway-deployment-template.yaml"
          },
          {
            name = "ParameterOverrides"
            value = jsonencode({
              "DockerImageUri" : "${module.aws_fastapi_lambda_api_gateway_ecr.ecr_repository_url}:#{SourceVariables.CommitId}",
              "FunctionName" : "${local.name_prefix}-fastapi-dynamodb-crud",
              "DynamoDBTableName" : aws_cloudformation_stack.dynamodb_table_stack.outputs["TableName"]
            })
          },
        ])
      }
    }
  }

  tags = merge(
    var.tags
  )

  depends_on = [module.aws_fastapi_lambda_api_gateway_ecr, module.codepipeline_artifact_store, module.codepipeline_iam_role, aws_codepipeline.cloudformation_template_codepipeline]
}

#---------------------------------------------------
# CloudFormation Template Deployment Pipeline
#---------------------------------------------------
resource "aws_codepipeline" "cloudformation_template_codepipeline" {
  name          = "${local.name_prefix}-cloudformation-template-codepipeline"
  pipeline_type = "V2"
  role_arn      = module.codepipeline_iam_role.codepipeline_iam_role_arn


  variable {
    name        = "StackName"
    description = "The name of an existing stack or a stack to be created."
  }

  variable {
    name          = "ActionMode"
    default_value = "CREATE_UPDATE"
    description   = "The action AWS CloudFormation performs on a stack or change set."
  }

  variable {
    name          = "Capabilities"
    default_value = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
    description   = "Use of Capabilities acknowledges that the template might have the capabilities to create and update some resources on its own."
  }

  variable {
    name        = "TemplatePath"
    description = "Represents the AWS CloudFormation template file."
  }

  variable {
    name        = "ParameterOverrides"
    description = "Parameters defined in the stack template and provide values for them at the time of stack creation or update."
  }

  artifact_store {
    location = module.codepipeline_artifact_store.s3_bucket
    type     = "S3"
    encryption_key {
      id   = module.codepipeline_artifact_store.s3_bucket_kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Pull_GitHub_Repository"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github_kwame_mintah.arn
        FullRepositoryId     = "kwame-mintah/aws-cloudformation-playground"
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "false"
      }
    }
  }

  stage {
    name = "Approval"

    # Manual approval action
    # https://docs.aws.amazon.com/codepipeline/latest/userguide/approvals-action-add.html
    action {
      name     = "Deployment_Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {}
    }
  }

  stage {
    name = "CloudFormation"

    # CloudFormation build action reference
    # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CloudFormation.html
    action {
      name            = "Deploy_CloudFormation_Stack"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ActionMode         = "#{variables.ActionMode}"
        StackName          = "#{variables.StackName}"
        TemplatePath       = "source_output::#{variables.TemplatePath}"
        Capabilities       = "#{variables.Capabilities}"
        RoleArn            = aws_iam_role.cloudformation_provider_role.arn
        ParameterOverrides = "#{variables.ParameterOverrides}"
      }
    }
  }

  tags = merge(
    var.tags
  )
}
