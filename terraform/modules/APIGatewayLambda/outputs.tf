/*
File: terraform/modules/APIGatewayLambda/outputs.tf

Author: Vijay Neethipudi
Date: Feb 12 2023
*/

output "restapi_base_url" {
  value = toset([
    for url in aws_api_gateway_stage.restapi_stage : url.invoke_url
  ])
}

output "endpoints" {
  value = {
    dynamodb_crud = aws_api_gateway_resource.dynamodb_crud.path
  }
}

output "lambda_latest_version" {
  value = {
    dynamodb_crud = aws_lambda_function.dynamodb_crud.version
  }
}