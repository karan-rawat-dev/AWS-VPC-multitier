resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-tier-subnet-group"
  subnet_ids = [aws_subnet.db_private_a.id, aws_subnet.db_private_b.id]
  tags       = { Name = "db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier             = "dev-app-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  db_name                = "appdb"
  username               = "dbadmin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}
