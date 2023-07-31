/*
File: terraform/modules/IAM/data.tf

Author: Vijay Neethipudi
Date: Feb 12 2023

Terraform code to create data resources for IAM Policies used by IAM Roles
*/

########################################################################################################################
# Data Polices
########################################################################################################################
# Lambda - Assumed role
data "aws_iam_policy_document" "lambda_assumed_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = "LambdaAssumedPolicy"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

# Lambda - EC2 and CloudWatch access for dynamodb_crud lambda
data "aws_iam_policy_document" "dynamodb_crud" {
  version = "2012-10-17"
  statement {
    actions = [
      "ec2:Describe*"
    ]
    effect    = "Allow"
    sid       = "LambdaEC2DescribeOnly"
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    sid    = "AllowCreateLogs"
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:*"
    ]
  }
}
