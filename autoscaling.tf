# =====================================
# Auto Scaling Group (ASG)
# =====================================
resource "aws_autoscaling_group" "petshop_asg" {
  name                      = "petshop-asg"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 120

  # ✅ Usa directamente las subredes públicas
  vpc_zone_identifier = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  # ✅ Referencia al Launch Template
  launch_template {
    id      = aws_launch_template.petshop_lt.id
    version = "$Latest"
  }

  # ✅ Asocia con el Target Group del ALB
  target_group_arns = [aws_lb_target_group.petshop_tg.arn]

  # ✅ Etiqueta para identificar instancias
  tag {
    key                 = "Name"
    value               = "petshop-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =====================================
# Auto Scaling Policy (CPU)
# =====================================
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "petshop-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.petshop_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
