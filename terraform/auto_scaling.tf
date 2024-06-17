resource "aws_launch_template" "tp-001" {
  name_prefix            = "node"
  image_id               = var.ami_default
  instance_type          = var.instance_type
  tags                   = var.default_tags_estagio
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.sg-002.id]
  iam_instance_profile { name = aws_iam_instance_profile.ssm-profile.name }
  tag_specifications {
    resource_type = "instance"
    tags          = var.default_tags_estagio

  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.default_tags_estagio
  }
  user_data = filebase64("../user_data.sh")

}




resource "aws_autoscaling_group" "atg-001" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [aws_subnet.pb-001.id, aws_subnet.pb-002.id]
  target_group_arns   = [aws_lb_target_group.tg001.arn]
  launch_template {
    id      = aws_launch_template.tp-001.id
    version = "$Latest"
  }
  depends_on = [aws_db_instance.default]
}

