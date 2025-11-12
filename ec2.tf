resource "aws_instance" "app" {
  ami                         = local.selected_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  key_name = var.key_name != "" ? var.key_name : null
  iam_instance_profile = var.instance_profile != "" ? var.instance_profile : null

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "petshop-app-instance"
  }
}
