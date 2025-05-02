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
