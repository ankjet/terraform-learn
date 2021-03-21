provider "aws" {
 region = "ap-south-1"
  # access_key = "AKIAQ26DSWGPLMJ5HGH5"
  # secret_key = "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"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    # type = "test"
    # Name = "${var.env_prefix}_VPC123"
    Name = "${var.env_prefix}_HULLLLOOOOOO"
  }
}
output "ankush" {
  value = aws_vpc.myapp-vpc.id
}

module "myapp-subnet" {
  source            = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone        = var.avail_zone
  env_prefix        = var.env_prefix
  vpc_id            = aws_vpc.myapp-vpc.id
}
resource "aws_security_group" "allow_tcp_http" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id


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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance-type
  tags = {
    Name = "${var.env_prefix}-app-server"
  }
  subnet_id                   = module.myapp-subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_tcp_http.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = "server-key-pair.${count.index}"
  count = 2

  user_data = file("entry-script.sh")
} 

variable "private_subnet_names" {
  type    = list(string)
  default = ["private_subnet_a", "private_subnet_b", "private_subnet_c"]
}

output "huha" {
  value = length(var.private_subnet_names)
}