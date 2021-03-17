provider "aws" {
    region = "ap-south-1"
    # access_key = "AKIAQ26DSWGPLMJ5HGH5"
    # secret_key = "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"
}
variable "subnet_cidr_block" {
    description = "subnet cidr"  
    type = list
}

variable "vpc_cidr_block" {
  description = "VPC CIDR variable"
  default = "10.0.0.0/16"
  type = string
}
resource "aws_vpc" "test-vpc" {
  cidr_block = var.subnet_cidr_block[1]
  tags = {
    # type = "test"
    Name = "QA_VPC"
  }
}

resource "aws_subnet" "test-subnet-1" {
  vpc_id     = aws_vpc.test-vpc.id 
  cidr_block = var.subnet_cidr_block[0]
  availability_zone = "ap-south-1a"
  tags = {
    type = "test"
    Name = "QA_subnet"
  }
}

output "test-vpc-id" {
    value = aws_vpc.test-vpc.id
  
}
output "test-subnet1-id" {
  value = aws_subnet.test-subnet-1.id
} 
