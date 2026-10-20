resource "aws_vpc_peering_connection" "app_to_db" {
  vpc_id      = aws_vpc.app_vpc.id
  peer_vpc_id = aws_vpc.db_vpc.id
  auto_accept = true

  tags = { Name = "app-to-db-peering" }
}

resource "aws_route" "app_priv_to_db" {
  route_table_id            = aws_route_table.app_private_rt.id
  destination_cidr_block    = var.db_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_db.id
}

resource "aws_route" "db_priv_to_app" {
  route_table_id            = aws_route_table.db_private_rt.id
  destination_cidr_block    = var.app_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_db.id
}
