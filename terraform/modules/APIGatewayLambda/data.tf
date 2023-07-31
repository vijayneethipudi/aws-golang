/*
File: terraform/modules/APIGatewayLambda/data.tf

Author: Vijay Neethipudi
Date: Feb 13 2023

Terraform code to create Data policies to be used by IAM Roles
*/

########################################################################################################################
# Data Policies
########################################################################################################################
# API Gateway Assumed role
data "aws_iam_policy_document" "api_assumed_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = "APIInvokeLambdaPolicy"
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
  }
}
########################################################################################################################

