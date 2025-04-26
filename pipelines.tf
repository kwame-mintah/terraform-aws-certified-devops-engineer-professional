resource "aws_codepipeline" "lambda_codepipeline" {
  name          = "${local.name_prefix}-lambda-pipeline"
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

      configuration = {
        # CodeStarSourceConnection for GitHub
        # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html#action-reference-CodestarConnectionSource-config
        ConnectionArn        = aws_codestarconnections_connection.github_kwame_mintah.arn
        FullRepositoryId     = "kwame-mintah/aws-lambda-data-preprocessing"
        BranchName           = "main"
        DetectChanges        = "true"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "ECR"

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
        ECRRepositoryName = module.lambda_data_preprocessing_ecr.ecr_repository_name
        DockerFilePath    = "."
        ImageTags         = "latest"
        RegistryType      = "private"
      }
    }
  }

  tags = merge(
    var.tags
  )

  depends_on = [module.lambda_data_preprocessing_ecr, module.codepipeline_artifact_store, module.codepipeline_iam_role]
}
