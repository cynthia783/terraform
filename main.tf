terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_s3_bucket" "my-terr-bucket" {
  bucket = "my-terr-bucket"

  tags = {
    Name = "My-bucket-terraform"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "my-subnet"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-aws_internet_gateway.id
  }

  tags = {
    Name = "route"
  }
}

resource "aws_internet_gateway" "my-aws_internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "m-group-de-secu" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-group-de-secu"
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "my_key" {
  key_name   = "mykey"
  public_key = file("~/.ssh/mykey.pub")

  tags = {
    Name = "mykey"
  }
}

resource "aws_instance" "ubuntu" {
  count                       = 3
  ami                         = "ami-06e02ae7bdac6b938"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.m-group-de-secu.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.my_key.key_name
  /*
  depends_on = [
    aws_security_group.m-group-de-secu
  ]
*/
  tags = {
    Name = "instance-${count.index + 1}"
  }
}