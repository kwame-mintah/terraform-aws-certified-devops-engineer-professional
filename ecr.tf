# Ideally, ECR repositories would not be deployed to each AWS environment / account.
# A shared location can be used and access given for each account to perform
# necessary actions.

module "aws_fastapi_lambda_api_gateway_ecr" {
  source                 = "./modules/ecr"
  repository_name        = "${var.project_name}-aws-fastapi-lambda-api-gateway"
  principles_identifiers = [module.codepipeline_iam_role.codepipeline_iam_role_arn]

  tags = merge(
    var.tags,
    {
      image_source = "https://github.com/kwame-mintah/aws-fastapi-lambda-api-gateway"
    }
    , {
      git_commit           = "5f370104830aadffcb0cf1c2dd23bfdf2c87db0c"
      git_file             = "ecr.tf"
      git_last_modified_at = "2025-05-21 20:29:19"
      git_last_modified_by = "kwame_mintah@hotmail.co.uk"
      git_modifiers        = "kwame_mintah"
      git_org              = "kwame-mintah"
      git_repo             = "terraform-aws-certified-devops-engineer-professional"
      yor_name             = "aws_fastapi_lambda_api_gateway_ecr"
      yor_trace            = "af221141-c805-49ad-bd64-2cd40f0fbc8b"
  })
}
