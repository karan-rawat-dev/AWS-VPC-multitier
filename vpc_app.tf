resource "aws_vpc" "app_vpc" {
  cidr_block           = var.app_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "app-vpc" }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags   = { Name = "app-igw" }
}

resource "aws_subnet" "app_public_a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "app-public-1a" }
}

resource "aws_subnet" "app_public_b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "app-public-1b" }
}

resource "aws_subnet" "app_private_a" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "app-private-1a" }
}

resource "aws_route_table" "app_public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = { Name = "app-public-rt" }
}

resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.app_public_a.id
  route_table_id = aws_route_table.app_public_rt.id
}

resource "aws_route_table_association" "pub_b" {
  subnet_id      = aws_subnet.app_public_b.id
  route_table_id = aws_route_table.app_public_rt.id
}

resource "aws_route_table" "app_private_rt" {
  vpc_id = aws_vpc.app_vpc.id
  tags   = { Name = "app-private-rt" }
}

resource "aws_route_table_association" "priv_a" {
  subnet_id      = aws_subnet.app_private_a.id
  route_table_id = aws_route_table.app_private_rt.id
}
