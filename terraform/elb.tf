resource "aws_lb" "lb001" {
  name               = "teste-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-001.id]
  subnets            = [aws_subnet.pb-001.id, aws_subnet.pb-002.id]
  tags               = var.default_tags_estagio


}


resource "aws_lb_target_group" "tg001" {
  name        = "tg001"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-tf.id
  target_type = "instance"
  tags        = var.default_tags_estagio

}



resource "aws_autoscaling_attachment" "atach_tg01_atg001" {
  autoscaling_group_name = aws_autoscaling_group.atg-001.id
  lb_target_group_arn    = aws_lb_target_group.tg001.arn
  depends_on             = [aws_autoscaling_group.atg-001]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb001.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg001.arn
  }
}

