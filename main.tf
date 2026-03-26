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


resource "aws_vpc" "VPC1" {

cidr_block = "10.0.0.0/16"

tags = {

  Name = "VPC1"
  created_time = formatdate("YYYY-MM-DD hh:mm ZZZ",timestamp())

}
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

tags = {

Name = "Main IGW"

}
}



resource "aws_route_table" "internet" {

vpc_id = aws_vpc.VPC1.id


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
vpc_id = aws_vpc.VPC1.id

ingress {

from_port = 0
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]

}

egress {

from_port =  22
to_port = 0
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
}


resource "aws_route_table_assoiation" "Public_access" {

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
