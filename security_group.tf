resource "aws_security_group" "petshop_app_sg" {
  name        = "petshop-app-sg-v8-full"
  description = "Allow HTTP and app traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "petshop-app-sg-v8-full"
  }
}

resource "aws_security_group" "petshop_rds_sg" {
  name        = "petshop-rds-sg-v8-full"
  description = "Allow MySQL from petshop app SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.petshop_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "petshop-rds-sg-v8-full"
  }
}
