
terraform {



  required_providers {
    aws = {
      source  = "hashicorp/aws"
 version = "~> 5.0"     
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

cidr = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24"]
public_subnets = ["10.0.2.0/24"]


  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}




resource "aws_internet_gateway" "IGW" {

vpc_id = module.VPC.vpc_id

tags = {

Name = "Main IGW"

}
}



resource "aws_route_table" "internet" {

vpc_id = module.VPC.vpc_id


route {

cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.IGW.id

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



resource "aws_security_group" "SSH_SG1" {

name = "allow_SSH"
vpc_id = module.VPC.vpc_id

ingress {

from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]

}

egress {

from_port =  22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]



}

ingress {

from_port = 0
to_port = 0
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"]



}

egress {

from_port = 0
to_port = 0
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"]

}

tags = {

Name = "VM1-SG"
}
}

resource "aws_route_table_association" "Public_access" {

subnet_id = aws_subnet.Public.id
route_table_id = aws_route_table.internet.id

}


# Add .gitignore file in this directory with the terraform.tfvars

resource "aws_instance" "tc_instance" {
  ami     = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.Public.id
  key_name = aws_key_pair.ubuntu.key_name
  vpc_security_group_ids = [aws_security_group.SSH_SG1.id]
  
  
  

  tags = {
    Name = "TC-triggered-instance"
  }
}
