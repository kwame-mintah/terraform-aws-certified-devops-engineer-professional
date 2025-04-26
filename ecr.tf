# Ideally, ECR repositories would not be deployed to each AWS environment / account.
# A shared location can be used and access given for each account to perform
# necessary actions.

module "lambda_data_preprocessing_ecr" {
  source                 = "./modules/ecr"
  repository_name        = "${var.project_name}-data-preprocessing"
  principles_identifiers = [module.codepipeline_iam_role.codepipeline_iam_role_arn]

  tags = merge(
    var.tags,
    {
      image_source = "https://github.com/kwame-mintah/aws-lambda-data-preprocessing"
    }
  )
}
