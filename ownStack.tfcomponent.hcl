required_providers {
  aws = {
    source = "hashicorp/aws"
    version = "6.61.6"
  }
}


provider "aws" "configurations" {
  
  config {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_access
  }

}


variable "users_list" {
  
  type = list(string)

}

variable "aws_access_key" {
  
}


variable "aws_secret_access" {
  
}

variable "environment" {
  
}

variable "region" {
  
}


component "iam_users" {
  
   source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "6.8.2"





for_each = toset(var.users_list)



inputs = {

  provider = aws.configurations
  name = each.key
tags = {

 enviroment = var.environment
}
}
}




