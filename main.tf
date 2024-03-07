provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
    eks = "cluster"
  }
}

resource "aws_subnet" "my_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "my_subnet1"
    eks = "cluster"
  }
}

resource "aws_subnet" "my_subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "my_subnet2"
    eks = "cluster"
  }
}

resource "aws_subnet" "my_subnet_pub1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet_pub1"
  }
}

resource "aws_subnet" "my_subnet_pub2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet_pub2"
  }
}

resource "aws_eip" "my_eip" {
  network_border_group = "us-west-2"
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.my_subnet_pub1.id

  tags = {
    Name = "my_nat"
  }
}

resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_ig"
  }
}

resource "aws_route_table" "my_rt1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "my_rt1"
  }
}

resource "aws_route_table" "my_rt2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "my_rt2"
  }
}

resource "aws_route_table" "my_rt3" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = "my_rt3"
  }
}

resource "aws_route_table_association" "my_association1" {
  subnet_id      = aws_subnet.my_subnet1.id
  route_table_id = aws_route_table.my_rt1.id
}

resource "aws_route_table_association" "my_association2" {
  subnet_id      = aws_subnet.my_subnet2.id
  route_table_id = aws_route_table.my_rt2.id
}

resource "aws_route_table_association" "my_association3" {
  subnet_id      = aws_subnet.my_subnet_pub1.id
  route_table_id = aws_route_table.my_rt3.id
}

resource "aws_route_table_association" "my_association4" {
  subnet_id      = aws_subnet.my_subnet_pub2.id
  route_table_id = aws_route_table.my_rt3.id
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_id_1" {
  value = aws_subnet.my_subnet1.id
}

output "subnet_id_2" {
  value = aws_subnet.my_subnet2.id
}
