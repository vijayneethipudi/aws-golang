/*
File: terraform/modules/IAM/main.tf

Author: Vijay Neethipudi
Date: Feb 12 2023

Terraform code to create AWS IAM Policies/Roles used by Lambda/Other resources
*/

########################################################################################################################
# IAM Role/Policy
########################################################################################################################
# IAM Role - compute instances lambda
resource "aws_iam_role" "dynamodb_crud" {
  name               = "${var.env}-dynamodb-crud"
  assume_role_policy = data.aws_iam_policy_document.lambda_assumed_role.json
  tags               = merge(tomap({ "access-env" = var.env }), var.tags)
}

# IAM Policy - Inline policy for role
resource "aws_iam_role_policy" "dynamodb_crud" {
  name   = "${var.env}-dynamodb-crud-lambda-cw-logs"
  policy = data.aws_iam_policy_document.dynamodb_crud.json
  role   = aws_iam_role.dynamodb_crud.id
}
########################################################################################################################
