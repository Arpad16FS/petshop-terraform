resource "aws_launch_template" "petshop_lt" {
  name_prefix   = "petshop-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  iam_instance_profile { 
    name = var.instance_profile 
  }

  vpc_security_group_ids = [aws_security_group.petshop_sg.id]

  user_data = filebase64("${path.module}/user_data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "petshop-autoscale-instance" }
  }
}
