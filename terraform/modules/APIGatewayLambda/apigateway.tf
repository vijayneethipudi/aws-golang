/*
File: terraform/modules/APIGatewayLambda/apigateway.tf

Author: Vijay Neethipudi
Date: Feb 12 2023

Terraform code to create AWS APIGateway resources
*/

########################################################################################################################
# API Gateway Resources
########################################################################################################################
# RestAPI
resource "aws_api_gateway_rest_api" "restapi" {
  name        = "${var.env}-${var.region}-restapi-golang"
  description = "API Gateway for GO Language Learning"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = merge(tomap({ "access-env" = var.env }), var.tags)
}

# RestAPI - Deployment
resource "aws_api_gateway_deployment" "restapi" {
  rest_api_id = aws_api_gateway_rest_api.restapi.id
  triggers = {
    redeployment = sha1(timestamp())
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.dynamodb_crud,
  ]
}

# RestAPI - Stage Creation
resource "aws_api_gateway_stage" "restapi_stage" {
  for_each      = var.api_stages
  deployment_id = aws_api_gateway_deployment.restapi.id
  rest_api_id   = aws_api_gateway_rest_api.restapi.id
  stage_name    = each.key
  variables     = each.value["stage_variables"]
  tags          = merge(tomap({ "access-env" = var.env }), var.tags)
}
########################################################################################################################
