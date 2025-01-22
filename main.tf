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
  region  = "eu-west-3"
}

resource "aws_instance" "ubuntu" {
  count = 3
  ami           = "ami-06e02ae7bdac6b938"
  instance_type = "t2.micro"

   tags = {
    Name = "instance-${count.index + 1}"
  }
}

resource "aws_s3_bucket" "my-terr-bucket" {
  bucket = "my-terr-bucket"

  tags = {
    Name        = "My-bucket-terraform"
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
  cidr_block              = "192.168.17.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "my-subnet"
  }
}

resource "aws_internet_gateway" "my-aws_internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igt"
  }
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
}

resource "aws_key_pair" "my_key" {
  key_name   = "ssh-terraform"
  public_key = file("${path.module}/ssh-terraform.pub")
}