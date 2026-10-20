resource "aws_vpc" "db_vpc" {
  cidr_block           = var.db_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "db-vpc" }
}

resource "aws_subnet" "db_private_a" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "db-private-1a" }
}

resource "aws_subnet" "db_private_b" {
  vpc_id            = aws_vpc.db_vpc.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "db-private-1b" }
}

resource "aws_route_table" "db_private_rt" {
  vpc_id = aws_vpc.db_vpc.id
  tags   = { Name = "db-private-rt" }
}

resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_private_a.id
  route_table_id = aws_route_table.db_private_rt.id
}

resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_private_b.id
  route_table_id = aws_route_table.db_private_rt.id
}
