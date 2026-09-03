terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.61.0"
    }
    
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  
 most_recent = true
 owners = ["amazon"]

 filter {
   name = "name"
   values = ["al2023-ami-*-x86_64"]
 }

 filter {

name = "virtualization-type"
values = ["hvm"]

 }
  
}



resource "aws_instance" "LAB1" {

  ami = data.aws_ami.amazon_linux.id
  count = 3
  instance_type = var.instance_type

  tags = {
    name = "instance-${count.index}"
  }

lifecycle {
  precondition {
    condition = !contains(["t2.micro","t2.micro"],var.instance_type)
    error_message = "instance type not matches the allowed t2.micro or t3.micro got ${var.instance_type} instead"
  }
}

  
}

variable "instance_type" {
  
}