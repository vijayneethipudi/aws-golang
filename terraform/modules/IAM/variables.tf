/*
File: terraform/modules/IAM/variables.tf

Author: Vijay Neethipudi
Date: Feb 12 2023
*/

variable "account_id" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}
