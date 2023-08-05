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
    dynamodb_crud = aws_api_gateway_resource.dynamodb_crud.path,
    hello_world   = aws_api_gateway_resource.hello_world.path
  }
}

output "lambda_latest_version" {
  value = {
    dynamodb_crud = aws_lambda_function.dynamodb_crud.version,
    hello_world   = aws_lambda_function.hello_world.version
  }
}
