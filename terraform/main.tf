/*
File: terraform/main.tf

Author: Vijay Neethipudi
Date: Feb 12 2023

Terraform code to create AWS Resources in modularized approach
*/

########################################################################################################################
# IAM Module - Policies and Roles
########################################################################################################################
module "IAM" {
  source     = "./modules/IAM"
  account_id = var.account_id
  env        = var.env
  region     = var.region
  tags       = var.tags
}
########################################################################################################################

########################################################################################################################
# API Gateway and Lambda Module
########################################################################################################################
module "APIGatewayLambda" {
  source                  = "./modules/APIGatewayLambda"
  ddb_crud_build_paths    = local.paths.dynamodbCrud
  hello_world_build_paths = local.paths.helloWorld
  account_id              = var.account_id
  api_stages              = var.api_stages
  deployment_bucket_id    = var.deployment_bucket_id
  env                     = var.env
  lambda_config           = var.lambda_config
  go_config               = var.go_config
  lambda_execution_role_arn = {
    "dynamodb_crud" = module.IAM.dynamodb_crud_role_arn,
    "hello_world"   = module.IAM.dynamodb_crud_role_arn
  }
  publish_lambda_version = var.publish_lambda_version
  region                 = var.region
  tags                   = var.tags
  depends_on = [
    module.IAM,
  ]
}
########################################################################################################################
