variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "aws_vpc" {
  type = string
  default = "10.10.0.0/16"
}

variable "aws_subnet" {
  type = string
  default = "10.10.1.0/24"
  
}

variable "aws_route_table" {
  type = string
  default = "0.0.0.0/0"
  
}
