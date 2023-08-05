/*
File: terraform/modules/APIGatewayLambda/lambda.tf

Author: Vijay Neethipudi
Date: Feb 12 2023

Terraform code to create AWS APIGateway / Lambda resources
*/

########################################################################################################################
# API Gateway Resources
########################################################################################################################
# RestAPI - env resource
resource "aws_api_gateway_resource" "env" {
  parent_id   = aws_api_gateway_rest_api.restapi.root_resource_id
  path_part   = var.env
  rest_api_id = aws_api_gateway_rest_api.restapi.id
}

# RestAPI - compute instance resource
resource "aws_api_gateway_resource" "dynamodb_crud" {
  parent_id   = aws_api_gateway_resource.env.id
  path_part   = "dynamodb-crud"
  rest_api_id = aws_api_gateway_rest_api.restapi.id
}

# RestAPI - compute instance method
resource "aws_api_gateway_method" "dynamodb_crud" {
  authorization = "NONE"
  # authorizer_id = aws_api_gateway_authorizer.authorizer.id
  http_method = "GET"
  resource_id = aws_api_gateway_resource.dynamodb_crud.id
  rest_api_id = aws_api_gateway_rest_api.restapi.id
}

# RestAPI - Hello world
resource "aws_api_gateway_resource" "hello_world" {
  parent_id   = aws_api_gateway_resource.env.id
  path_part   = "hello-world"
  rest_api_id = aws_api_gateway_rest_api.restapi.id
}

# RestAPI - Hello World
resource "aws_api_gateway_method" "hello_world" {
  authorization = "NONE"
  # authorizer_id = aws_api_gateway_authorizer.authorizer.id
  http_method = "GET"
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.restapi.id
}
########################################################################################################################

########################################################################################################################
# Lambda Resources
########################################################################################################################
# Lambda - compute instances - archive file

// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "dynamodb_crud" {
  type        = "zip"
  source_file = var.ddb_crud_build_paths["binary_path"]
  output_path = var.ddb_crud_build_paths["archive_path"]
}


# data "archive_file" "dynamodb_crud" {
#   type        = "zip"
#   source_file = "${path.cwd}/src/dynamoCrud/main"
#   output_path = "${path.cwd}/src/dynamoCrud/main.zip"
# }

resource "aws_s3_object" "dynamodb_crud" {
  bucket = var.deployment_bucket_id # "dev-us-east-1-deployment-packages"
  key    = "dynamoCrud/main.zip"
  source = data.archive_file.dynamodb_crud.output_path
  # etag   = filemd5(data.archive_file.dynamodb_crud.output_path)
}

resource "aws_lambda_function" "dynamodb_crud" {
  function_name     = "${var.env}-${var.region}-dynamodb-crud"
  description       = "Perform crud operation on dynamodb"
  s3_bucket         = var.deployment_bucket_id
  s3_key            = aws_s3_object.dynamodb_crud.key
  handler           = var.go_config["handler"]
  publish           = var.publish_lambda_version["dynamodb_crud"]
  s3_object_version = aws_s3_object.dynamodb_crud.version_id
  source_code_hash  = data.archive_file.dynamodb_crud.output_base64sha256
  role              = var.lambda_execution_role_arn["dynamodb_crud"]
  runtime           = var.go_config["runtime"] # go1.x
  memory_size       = var.lambda_config["memory_size"]
  timeout           = var.lambda_config["timeout"]
}

# Lambda - compute instances - API Gateway - Lambda permissions
resource "aws_lambda_permission" "dynamodb_crud" {
  for_each      = var.api_stages
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_crud.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.restapi.id}/*/${aws_api_gateway_method.dynamodb_crud.http_method}${aws_api_gateway_resource.dynamodb_crud.path}"
  qualifier     = aws_lambda_alias.dynamodb_crud[each.key].name
}

# Lambda - compute instances - alias
resource "aws_lambda_alias" "dynamodb_crud" {
  for_each         = var.api_stages
  name             = each.value["stage_variables"]["dynamodb_crud_lambda"]
  description      = "lambda alias for dynamodb_crud lambda function"
  function_name    = aws_lambda_function.dynamodb_crud.function_name
  function_version = each.value["alias_variables"]["dynamodb_crud_lambda"]["version"]
}

# RestAPI - Method and Lambda function integration
resource "aws_api_gateway_integration" "dynamodb_crud" {
  http_method             = aws_api_gateway_method.dynamodb_crud.http_method
  resource_id             = aws_api_gateway_resource.dynamodb_crud.id
  rest_api_id             = aws_api_gateway_rest_api.restapi.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.dynamodb_crud.arn}:$${stageVariables.dynamodb_crud_lambda}/invocations"
}
########################################################################################################################

// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "hello_world" {
  type        = "zip"
  source_file = var.hello_world_build_paths["binary_path"]
  output_path = var.hello_world_build_paths["archive_path"]
}


# data "archive_file" "hello_world" {
#   type        = "zip"
#   source_file = "${path.cwd}/src/dynamoCrud/main"
#   output_path = "${path.cwd}/src/dynamoCrud/main.zip"
# }

resource "aws_s3_object" "hello_world" {
  bucket = var.deployment_bucket_id # "dev-us-east-1-deployment-packages"
  key    = "helloWorld/main.zip"
  source = data.archive_file.hello_world.output_path
  # etag   = filemd5(data.archive_file.hello_world.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name     = "${var.env}-${var.region}-hello-world"
  description       = "Hello world lambda"
  s3_bucket         = var.deployment_bucket_id
  s3_key            = aws_s3_object.hello_world.key
  handler           = var.go_config["handler"]
  publish           = var.publish_lambda_version["hello_world"]
  s3_object_version = aws_s3_object.hello_world.version_id
  source_code_hash  = data.archive_file.hello_world.output_base64sha256
  role              = var.lambda_execution_role_arn["hello_world"]
  runtime           = var.go_config["runtime"] # go1.x
  memory_size       = var.lambda_config["memory_size"]
  timeout           = var.lambda_config["timeout"]
}

# Lambda - compute instances - API Gateway - Lambda permissions
resource "aws_lambda_permission" "hello_world" {
  for_each      = var.api_stages
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.restapi.id}/*/${aws_api_gateway_method.hello_world.http_method}${aws_api_gateway_resource.hello_world.path}"
  qualifier     = aws_lambda_alias.hello_world[each.key].name
}

# Lambda - compute instances - alias
resource "aws_lambda_alias" "hello_world" {
  for_each         = var.api_stages
  name             = each.value["stage_variables"]["hello_world_lambda"]
  description      = "lambda alias for hello_world lambda function"
  function_name    = aws_lambda_function.hello_world.function_name
  function_version = each.value["alias_variables"]["hello_world_lambda"]["version"]
}

# RestAPI - Method and Lambda function integration
resource "aws_api_gateway_integration" "hello_world" {
  http_method             = aws_api_gateway_method.hello_world.http_method
  resource_id             = aws_api_gateway_resource.hello_world.id
  rest_api_id             = aws_api_gateway_rest_api.restapi.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_world.arn}:$${stageVariables.hello_world_lambda}/invocations"
}
########################################################################################################################
