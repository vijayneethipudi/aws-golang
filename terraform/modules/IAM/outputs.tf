/*
File: terraform/modules/IAM/outputs.tf

Author: Vijay Neethipudi
Date: Feb 12 2023
*/

output "dynamodb_crud_role_arn" {
  value = aws_iam_role.dynamodb_crud.arn
}
