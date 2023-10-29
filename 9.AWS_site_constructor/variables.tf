variable "aws_region" {
  default = "eu-north-1"
}

variable "admin_ip" {
  default = "217.28.48.78/32"
}

variable "instance_ami" {
  default     = "ami-0d915f72874e92f5e"
  description = "Custom AMI"
}

#----------------
# INPUT VARIABLES
#----------------

variable "instance_type" {
  default     = "t3.micro"
  description = "EC2 type"
}

variable "ssh_key" {
  type    = string
  default = "/Users/vklimantovich/.ssh/id_rsa.pub"
}

variable "instance_pub_ip" {
  default     = true
  description = "true/false"
}

variable "vpc_id" {
  default     = "vpc-0d9869e1d4fcbf87d"
  description = "Target VPC id"
}

variable "subnet_ids" {
  default     = ["subnet-0f31b540b57f21987", "subnet-0d28bb454b3b988fa"]
  description = "Target subnet id"
}

variable "instance_name" {
  default     = "task-web"
  description = "Name tag of webserver"
}

#----------------
