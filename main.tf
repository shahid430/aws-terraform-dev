resource "aws_vpc" "vpc-dev" {
  cidr_block = var.aws_vpc
  tags = {
    Name = "vpc-dev"
  }
  lifecycle {
    ignore_changes = [ cidr_block ]
  }
}

resource "aws_subnet" "subnet-dev" {
  vpc_id            = aws_vpc.vpc-dev.id
  cidr_block        = var.aws_subnet
  availability_zone = "us-east-1a"
  tags = { 
    Name = "subnet-dev"
  } 
}

resource "aws_internet_gateway" "igw-dev" {
  vpc_id = aws_vpc.vpc-dev.id
  tags = {
    Name = "igw-dev"
  }
}

resource "aws_eip" "eip-dev" {
    depends_on = [aws_internet_gateway.igw-dev]
}

resource "aws_eip_association" "eip-assoc-dev" {
    instance_id   = aws_instance.aws-instance.id
    allocation_id = aws_eip.eip-dev.id
}


resource "aws_route_table" "rtb-dev" {
    vpc_id = aws_vpc.vpc-dev.id
    route {
        cidr_block = var.aws_route_table
        gateway_id = aws_internet_gateway.igw-dev.id
    }
    tags = {
    Name = "dev-rtb"
    }
}


resource "aws_route_table_association" "rtb-assoc" {
    subnet_id      = aws_subnet.subnet-dev.id
    route_table_id = aws_route_table.rtb-dev.id
  
}

resource "aws_security_group" "security-group" {
  name        = "allow_ssh_http"
  vpc_id      = aws_vpc.vpc-dev.id
  description = "Allow SSH and HTTP traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}


resource "aws_instance" "aws-instance" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = var.instance_type
  security_groups = [aws_security_group.security-group.id]
  subnet_id = aws_subnet.subnet-dev.id
  associate_public_ip_address = true
  lifecycle {
    ignore_changes = [ security_groups]
  }
  tags = {
    Name = "Terraform-Instance"
}
  key_name = "aws-terraform"
}

