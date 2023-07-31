/*
File: terraform/variables.tf

Author: Vijay Neethipudi
Date: Feb 12 2023
*/

variable "tags" {
  type = map(any)
}

variable "account_id" {
  type = string
}

variable "lambda_config" {
  type = map(any)
}

variable "publish_lambda_version" {
  type = map(any)
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "api_stages" {
  type = map(any)
}

variable "deployment_bucket_id" {
  type = string
}

variable "go_config" {
  type = map(string) 
}
