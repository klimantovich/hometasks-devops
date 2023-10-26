# ---------------------
# Generating of rsa key
# ---------------------

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}

# ---------------------
# Create EC2 instance for web-server
# ---------------------

resource "aws_network_interface" "net_interface" {
  count           = var.web-count
  subnet_id       = element(aws_subnet.public_subnet.*.id, count.index)
  security_groups = [aws_security_group.ssh-in.id, aws_security_group.web.id]
}

resource "aws_instance" "web-server" {
  count         = var.web-count
  ami           = var.web-ami
  instance_type = var.web-type
  key_name      = aws_key_pair.generated_key.key_name

  network_interface {
    network_interface_id = element(aws_network_interface.net_interface.*.id, count.index)
    device_index         = 0
  }

  user_data = <<-EOT
#!/bin/bash
yum install -y nginx
systemctl enable nginx
systemctl start nginx
  EOT

  tags = {
    Name = "${var.env_prefix}-web-${count.index + 1}"
  }

}
