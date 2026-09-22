required_providers {
  aws = {
    source = "hashicorp/aws"
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
  
  type = list()

}

variable "aws_access_key" {
  
}


variable "aws_secret_key" {
  
}

variable "enviroment" {
  
}


component "iam_users" {
  
   source  = "terraform-aws-modules/iam/aws"
  version = "6.8.2"

for_each = toset(var.users_list)

  Name = each.key

tags = {

 enviroment = var.enviroment
}
}




