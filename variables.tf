variable "security_ingress" {
  type = map(number)
  default = {
    https = 443
    ssh = 22 
    SMPP = 3600
  }
}

variable "security_egress" {
  type = map(number)
default = {

    http = 80
    FTP = 20

}
}

variable "instance_type" {

    type = string
    default = "t2.micro"
}


