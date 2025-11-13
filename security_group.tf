resource "aws_security_group" "petshop_sg" {
  name        = "petshop-sg"
  description = "Allow HTTP traffic to ALB and app"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet (ALB)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP app port 8080"
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

  tags = { Name = "petshop-sg" }
}
