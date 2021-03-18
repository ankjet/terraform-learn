provider "aws" {
    region = "ap-south-1"
    # access_key = "AKIAQ26DSWGPLMJ5HGH5"
    # secret_key = "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"
}
variable "subnet_cidr_block" {}
variable "vpc_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my-ip" {}
variable "instance-type" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    # type = "test"
    Name = "${var.env_prefix}_VPC123"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    type = "test"
    Name = "${var.env_prefix}-subnet-1"
  }
}

# This is the route table
resource "aws_route_table" "myapp-rt" {
   vpc_id = aws_vpc.myapp-vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}_rtb"
  }
}

# This is the IGW
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}_igw"
  }
}

resource "aws_route_table_association" "name" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-rt.id
}

resource "aws_security_group" "allow_tcp_http" {
  name = "myapp-sg"
  vpc_id      = aws_vpc.myapp-vpc.id

  ingress {
    description = "TCP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my-ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
   filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
}
output "aws-ami" {
  value =  data.aws_ami.latest-amazon-linux-image.id
  
}
 resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance-type
  tags = {
    Name = "${var.env_prefix}-app-server"
  }
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.allow_tcp_http.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "server-key-pair"

  user_data = file("entry-script.sh")
} 