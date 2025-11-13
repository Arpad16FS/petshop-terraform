resource "aws_launch_template" "petshop_lt" {
  name_prefix   = "petshop-lt-v8-full-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.instance_profile
  }

  vpc_security_group_ids = [aws_security_group.petshop_app_sg.id]

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    db_host = aws_db_instance.petshop_rds.address
    db_user = var.db_user
    db_pass = var.db_pass
    db_name = var.db_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "petshop-ec2-v8-full"
    }
  }

  monitoring {
    enabled = true
  }
}
