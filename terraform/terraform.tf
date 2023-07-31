/*
File: terraform/terraform.tf

Author: Vijay Neethipudi
Date: Feb 12 2023

This file contains terraform workspace organization and workspace details state file being managed
*/

########################################################################################################################
# Terraform Workspace module
########################################################################################################################
terraform {
  cloud {
    organization = "aws-tfe-cloud"
    workspaces {
      name = "aws-github-golang"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
  }
  required_version = ">= 0.14.0"
}

provider "aws" {
  region = var.region
}
########################################################################################################################