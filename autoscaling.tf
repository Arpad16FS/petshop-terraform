resource "aws_autoscaling_group" "petshop_asg" {
  name                      = "petshop-asg-v8-full"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.petshop_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "petshop-asg-instance-v8-full"
    propagate_at_launch = true
  }
}
