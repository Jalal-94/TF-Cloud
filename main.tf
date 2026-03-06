terraform {



  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }



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


resource "aws_vpc" "VPC1" {

cidr_block = "10.0.0.0/16"

tags = {

  Name = "VPC1"
  created_time = formatdate("YYYY-MM-DD hh:mm ZZZ",timestamp())

}

resource "aws_subnet" "Private" {

vpc_id = aws_vpc.VPC1.id
cidr_block = "10.0.1.0/24"

}

resource "aws_subnet" "Public" {

vpc_id = aws_vpc.VPC1.id
cidr_block = "10.0.2.0/24"
map_public_ip_on_launch = true

}


resource "aws_internet_gateway" "IGW" {

vpc_id = aws_vpc.VPC1.id

tags {

Name = "Main IGW"

}
}



resource "aws_route_table" "internet" {

vpc_id = aws_vpc.id


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

# Add .gitignore file in this directory with the terraform.tfvars

resource "aws_instance" "tc_instance" {
  ami     = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Public.id
  key_name = aws_key_pair.ubuntu.key_name
  
  
  

  tags = {
    Name = "TC-triggered-instance"
  }
}
