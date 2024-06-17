resource "aws_vpc" "vpc-tf" {
  cidr_block           = "10.0.0.0/16"
  tags                 = var.default_tags_estagio
  enable_dns_hostnames = true
  enable_dns_support   = true

}

resource "aws_subnet" "pvt-001" {
  vpc_id            = aws_vpc.vpc-tf.id
  cidr_block        = "10.0.1.0/24"
  tags              = var.default_tags_estagio
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "pvt-002" {
  vpc_id            = aws_vpc.vpc-tf.id
  cidr_block        = "10.0.3.0/24"
  tags              = var.default_tags_estagio
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "pb-001" {
  vpc_id                  = aws_vpc.vpc-tf.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags                    = var.default_tags_estagio
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "pb-002" {
  vpc_id                  = aws_vpc.vpc-tf.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  tags                    = var.default_tags_estagio
  availability_zone       = "us-east-1b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-tf.id
  tags   = var.default_tags_estagio
}

resource "aws_route_table" "rt001" {
  vpc_id = aws_vpc.vpc-tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.default_tags_estagio
}

resource "aws_route_table_association" "pb-001-to-rt001" {
  subnet_id      = aws_subnet.pb-001.id
  route_table_id = aws_route_table.rt001.id
}

resource "aws_route_table_association" "pb-002-to-rt001" {
  subnet_id      = aws_subnet.pb-002.id
  route_table_id = aws_route_table.rt001.id
}