# ---------------------
# Create Load Balancer
# ---------------------

# Create target group for elb
resource "aws_lb_target_group" "targetgroup" {
  name     = "${var.env_prefix}-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled  = true
    path     = "/"
    timeout  = 2
    interval = 5
  }

  tags = {
    Name = "${var.env_prefix}-targetgroup"
  }
}

# Register ec2 web-server instances to targetgroup
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count            = var.web-count
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = element(aws_instance.web-server.*.id, count.index)
  port             = 80

  depends_on = [
    aws_instance.web-server
  ]
}

# Create Load Balancer
resource "aws_lb" "loadbalancer" {
  name               = "${var.env_prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {
    Name = "${var.env_prefix}-lb"
  }
}

# Create Load Balancer Listener rule
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}
