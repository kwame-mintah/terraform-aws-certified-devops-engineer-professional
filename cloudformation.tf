#---------------------------------------------------
# CloudFormation Stack Deployments
#---------------------------------------------------
data "http" "km_dynamodb_template" {
  request_headers = {
    Accept = "text/yaml"
  }
  url = "https://raw.githubusercontent.com/kwame-mintah/aws-cloudformation-playground/e81092ed4e6b27d887ef2dbb489bb8efa59a44f4/dynamodb-terraform-deployment-template.yaml"
}

data "http" "km_lambda_api_gateway_template" {
  request_headers = {
    Accept = "text/yaml"
  }
  url = "https://raw.githubusercontent.com/kwame-mintah/aws-cloudformation-playground/301746222955e9bf2f1c74c8177a51ba9b722c0d/lambda-api-gateway-deployment-template.yaml"
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

resource "aws_cloudformation_stack" "lambda_api_gateway_stack" {
  name               = "${local.name_prefix}-lambda-api-gateway-stack"
  timeout_in_minutes = 10
  capabilities       = ["CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]

  parameters = {
    DockerImageUri    = "827284457226.dkr.ecr.eu-west-2.amazonaws.com/devops-engineer-data-preprocessing:fdb984aff9953708f67ef098841d25ab1b7197cf"
    FunctionName      = "${local.name_prefix}-fastapi-dynamodb-crud"
    DynamoDBTableName = aws_cloudformation_stack.dynamodb_table_stack.outputs["TableName"]
  }
  template_body = data.http.km_lambda_api_gateway_template.response_body

  tags = merge(
    var.tags
  )
}
