# ===============================
# Security Group para el ALB
# ===============================
resource "aws_security_group" "alb_sg" {
  name        = "petshop-alb-sg"
  description = "Allow HTTP and HTTPS traffic to ALB"  # ❗ Solo ASCII (sin tildes ni ñ)
  vpc_id      = var.vpc_id  # Usamos la VPC por defecto definida en variables.tf

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "petshop-alb-sg"
  }
}

# ===============================
# Application Load Balancer (ALB)
# ===============================
resource "aws_lb" "petshop_alb" {
  name               = "petshop-alb"
  load_balancer_type = "application"
  internal           = false

  # ✅ Usa las subnets existentes definidas en variables.tf
  subnets = var.subnet_ids

  # ✅ Usa el security group recién creado
  security_groups = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false

  tags = {
    Name = "petshop-alb"
  }
}

# ===============================
# Target Group
# ===============================
resource "aws_lb_target_group" "petshop_tg" {
  name        = "petshop-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id  # ✅ Referencia directa a tu VPC existente

  health_check {
    path                = "/"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "petshop-tg"
  }
}

# ===============================
# Listener (puerto 80)
# ===============================
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.petshop_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.petshop_tg.arn
  }

  tags = {
    Name = "petshop-listener"
  }
}

