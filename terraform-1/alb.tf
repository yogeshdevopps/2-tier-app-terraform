# Deploy Application Load Balancer
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.albsg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}

# Create ALB Target Group
resource "aws_lb_target_group" "albtg" {
  name     = "albtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  depends_on = [aws_vpc.vpc]
}

# Deploy LB Target Attachments
resource "aws_lb_target_group_attachment" "tgattach1" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.instance1.id
  port             = 80

  depends_on = [aws_instance.instance1]
}

resource "aws_lb_target_group_attachment" "tgattach2" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.instance2.id
  port             = 80

  depends_on = [aws_instance.instance2]
}

# Deploy LB Listener
resource "aws_lb_listener" "lblisten" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albtg.arn
  }
}