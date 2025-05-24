<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.95.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.95.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_report_group.codebuild_test_report_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_report_group) | resource |
| [aws_kms_alias.kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_caller_identity.current_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Number of minutes, from 5 to 2160 (36 hours), for AWS CodeBuild to <br>wait until timing out any related build that does not get marked as completed. | `number` | `10` | no |
| <a name="input_buildspec_yml_file_location"></a> [buildspec\_yml\_file\_location](#input\_buildspec\_yml\_file\_location) | Local file path to the BuildSpec in a YAML-formatted file. | `string` | `null` | no |
| <a name="input_codebuild_report_group_name"></a> [codebuild\_report\_group\_name](#input\_codebuild\_report\_group\_name) | The name of a Report Group. | `string` | `""` | no |
| <a name="input_codepipeline_name"></a> [codepipeline\_name](#input\_codepipeline\_name) | The CodePipeline that will be utilising the CodeBuild compute. | `string` | n/a | yes |
| <a name="input_create_codebuild_test_report_group"></a> [create\_codebuild\_test\_report\_group](#input\_create\_codebuild\_test\_report\_group) | Create a CodeBuild test report project group, associated with the<br>buildspec provided. | `bool` | `false` | no |
| <a name="input_environment_compute_type"></a> [environment\_compute\_type](#input\_environment\_compute\_type) | Information about the compute resources the build project will use. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_environment_docker_image"></a> [environment\_docker\_image](#input\_environment\_docker\_image) | Docker image to use for this build project. <br>Valid values include [Docker images provided by CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html) | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Type of build environment to use for related builds. | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_name"></a> [name](#input\_name) | The CodeBuild Project's name. | `string` | n/a | yes |
| <a name="input_principles_identifiers"></a> [principles\_identifiers](#input\_principles\_identifiers) | List of ARNs that have access to th KMS key. | `list(string)` | `[]` | no |
| <a name="input_s3_report_bucket_name"></a> [s3\_report\_bucket\_name](#input\_s3\_report\_bucket\_name) | The name of the S3 bucket where the raw data of<br>a report are exported. | `string` | `""` | no |
| <a name="input_s3_report_encryption_key_arn"></a> [s3\_report\_encryption\_key\_arn](#input\_s3\_report\_encryption\_key\_arn) | The KMS key used to encrypt data stored within<br>the report bucket. | `string` | `""` | no |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | Amazon Resource Name (ARN) of the AWS Identity and Access Management (IAM)<br>role that enables AWS CodeBuild to interact with dependent AWS services on<br>behalf of the AWS account. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be added to resources created. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_project_name"></a> [codebuild\_project\_name](#output\_codebuild\_project\_name) | The name of the CodeBuild project created. |
<!-- END_TF_DOCS -->