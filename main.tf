
terraform {



  required_providers {
    aws = {
      source  = "hashicorp/aws"
 version = "~> 6.37"     
    }
  }


}


variable "public_key" {

  description = "for SSH access"
  type = string

}


data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical (official Ubuntu owner ID)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


module "VPC" {

source = "terraform-aws-modules/vpc/aws"
name = "Test_VPC"
azs = ["us-east-1a"]

cidr = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24"]
public_subnets = ["10.0.2.0/24"]


  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}




# Variable blocks directly within the main.tf. No arguments necessary.
#variable "aws_access_key" {}
#variable "aws_secret_key" {}

# provider arguments call on the variables which then call on terraform.tfvars for the values.
provider "aws" {
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
  region     = "us-east-1"
}


resource "aws_key_pair" "ubuntu" {

key_name = "ubuntu"
public_key = var.public_key

}

locals {

inbound_ports = [443,22,80]
outbound_ports = [443,22,80]

}


resource "aws_security_group" "SSH_SG1" {

name = "allow_application_ports"
vpc_id = module.VPC.vpc_id

dynamic "ingress" {

for_each = local.inbound_ports

content {

from_port = ingress.value
to_port = ingress.value
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]

}
}

dynamic "egress" {

for_each = local.outbound_ports

content {

from_port = egress.value
to_port = 65535
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}



tags = {

Name = "VM1-SG"
}
}




# Add .gitignore file in this directory with the terraform.tfvars

resource "aws_instance" "tc_instance" {
  ami     = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  count =2
  subnet_id = module.VPC.public_subnets[0]
  key_name = aws_key_pair.ubuntu.key_name
  vpc_security_group_ids = [aws_security_group.SSH_SG1.id]
  
  
  

  tags = {
    Name = "TC-triggered-instance-${count.index}"
	time_created = formatdate("YYYY-MM-DD hh:mm:ss ZZZ",timestamp())
  }
}
