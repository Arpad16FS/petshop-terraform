resource "aws_lb" "petshop_alb" {
  name               = "petshop-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.petshop_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = { Name = "petshop-alb" }
}

resource "aws_lb_target_group" "petshop_tg" {
  name     = "petshop-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    port                = "8080"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_listener" "petshop_listener" {
  load_balancer_arn = aws_lb.petshop_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.petshop_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.petshop_asg.id
  alb_target_group_arn   = aws_lb_target_group.petshop_tg.arn
}
