resource "aws_db_subnet_group" "petshop_rds_subnets" {
  name       = "petshop-rds-subnet-group-v8-full"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "petshop-rds-subnets-v8-full"
  }
}

resource "aws_db_instance" "petshop_rds" {
  identifier             = "petshop-db-v8-full"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_pass
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.petshop_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.petshop_rds_subnets.name

  tags = {
    Name = "petshop-rds-v8-full"
  }
}
