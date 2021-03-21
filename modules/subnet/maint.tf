resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = var.vpc_id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    type = "test"
    Name = "${var.env_prefix}-subnet-1"
  }
}

# This is the route table
resource "aws_route_table" "myapp-rt" {
   vpc_id = var.vpc_id  

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
  vpc_id = var.vpc_id 
  tags = {
    Name = "${var.env_prefix}_igw"
  }
}

resource "aws_route_table_association" "name" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-rt.id
}