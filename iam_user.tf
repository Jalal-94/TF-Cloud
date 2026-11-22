terraform {

  backend "s3" {
    bucket = "jalal-13102026"
    key = "dev/terraform.tfstate"
    region = "us-east-1"

  }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 6.60.6"
    }

  }

  required_version = ">= 1.15.0"
}

provider "aws" {

  region = "us-east-1"
}



module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "lab-vpc"
  cidr = "10.0.0.0/16"

}

resource "aws_subnet" "nets" {
  vpc_id = module.aws_vpc.vpc_id

  for_each = toset(cidrsubnets(module.aws_vpc.vpc_cidr_block,"8","8"))
  cidr_block = each.value

  tags = {

    Name = "private-${each.value}"
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



resource "aws_security_group" "SG1" {

  vpc_id = module.aws_vpc.vpc_id


 dynamic "ingress" {
   for_each = toset(values(var.security_ingress))
   content {

     from_port = ingress.value
     to_port = ingress.value
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]


   }
 }

 dynamic "egress" {
   for_each = toset(values(var.security_egress))
   content {

    from_port = egress.value
    to_port = egress.value
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]



   }
 }

}

resource "aws_instance" "LAB" {
  ami = "ami-00adafae70b8029d8"
  subnet_id = aws_subnet.nets["10.0.1.0/24"].id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SG1.id]
  depends_on = [ aws_security_group.SG1 ]
  count = 2


  lifecycle {


    postcondition {
      condition = self.instance_state=="running"
      error_message = "state not running please check"
    }
  }
  tags = {
    Name = "VM-${count.index}"
  }

}

