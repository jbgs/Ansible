provider "aws" {
  region  = "us-east-1"
  profile = "default"
}



resource "aws_vpc" "main" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet01"
  }
}

resource "aws_security_group" "sg01-ansible-class" {
  name = "allow-ssh"

  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible-tw" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.micro"

  key_name                    = "ansible-class"
  security_groups             = ["${aws_security_group.sg01-ansible-class.id}"]

  associate_public_ip_address = "true"
  subnet_id = aws_subnet.subnet01.id

  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "ansible-tw"
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ansible-tw.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ansible-tw.public_ip
}

