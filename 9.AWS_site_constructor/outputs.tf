output "instance_ip" {
  description = "Public IP of Instance"
  value       = aws_instance.web.public_ip
}

output "loadbalancer_dns" {
  description = "Load Balancer DNS"
  value       = aws_lb.loadbalancer.dns_name
}
