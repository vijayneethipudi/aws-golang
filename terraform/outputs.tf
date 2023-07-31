/*
File: terraform/outputs.tf

Author: Vijay Neethipudi
Date: Feb 12 2023
*/

# APIGateway Base URL
output "api_gateway_base_url" {
  value = {
    base_url : module.APIGatewayLambda.restapi_base_url,
    endpoints : module.APIGatewayLambda.endpoints
  }
}

# Latest Lambda Version
output "lambda_latest_version" {
  value = module.APIGatewayLambda.lambda_latest_version
}
