
# =====================================
# Launch Template (Plantilla EC2)
# =====================================
resource "aws_launch_template" "petshop_lt" {
  name_prefix   = "petshop-lt-"
  instance_type = "t2.micro"
  key_name      = var.key_name

  # ✅ AMI oficial Amazon Linux 2 (us-east-1)
  image_id = "ami-0c02fb55956c7d316"

  # ✅ Grupo de seguridad para las instancias
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # ✅ Script opcional de inicialización
  # (crea user_data.sh con la instalación de tu app o nginx)
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "petshop-instance"
    }
  }
}

# =====================================
# Security Group para las instancias
# =====================================
resource "aws_security_group" "app_sg" {
  name        = "petshop-app-sg"
  description = "Allow HTTP and SSH traffic for petshop app"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "petshop-app-sg"
  }
}

