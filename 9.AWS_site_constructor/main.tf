provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "generated_key" {
  key_name   = "task_keypair"
  public_key = file(var.ssh_key)
}

# ---------------------
# Create security group for web-server & load balancer
# ---------------------
resource "aws_security_group" "instance" {
  name        = "instance-sg"
  description = "Access to instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }
  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      description     = "HTTP/HHTPS from load balancer"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.load_balancer.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}

resource "aws_security_group" "load_balancer" {
  name        = "elb-sg"
  description = "Access to load balancer"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      description = "HTTPS from internet"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }
}

# ---------------------
# Create EC2 instance for web-server
# ---------------------
resource "aws_network_interface" "net_interface" {
  subnet_id       = var.subnet_ids[0]
  security_groups = [aws_security_group.instance.id]

}

resource "aws_instance" "web" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.net_interface.id
    device_index         = 0
  }

  tags = {
    Name = var.instance_name
  }

}

# ---------------------
# Create ELB
# ---------------------

# Create target group for elb
resource "aws_lb_target_group" "targetgroup" {
  name     = "task-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Register ec2 web-server instances to targetgroup
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.web.id
  port             = 80

  depends_on = [
    aws_instance.web
  ]
}

# Create Load Balancer
resource "aws_lb" "loadbalancer" {
  name               = "task-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {
    Name = "task-lb"
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
