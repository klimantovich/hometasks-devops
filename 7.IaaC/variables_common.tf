variable "aws_region" {
  default = "eu-west-3"
}

variable "env_prefix" {
  default = "task"
}

variable "admin_ip" {
  default = "217.28.48.78/32"
}

# ---------------------
# VPC - related variables
# ---------------------

variable "vpc_cidr" {
  default     = "10.5.0.0/16"
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  default     = ["10.5.0.0/20", "10.5.16.0/20"]
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  default     = ["10.5.32.0/20", "10.5.48.0/20"]
  description = "CIDR block for Private Subnet"
}

# ---------------------
# KeyPair - related variables
# ---------------------

variable "public_key_path" {
  type    = string
  default = "/Users/vklimantovich/.ssh/id_rsa.pub"
}

variable "key_pair_name" {
  type    = string
  default = "vitaly_keypair"
}

# ---------------------
# EC2-webserver - related variables
# ---------------------

variable "web-count" {
  default     = "2"
  description = "Number of ec2 web-servers"
}

variable "web-ami" {
  default     = "ami-0a4b7ff081ca1ded9"
  description = "Amazon Linux AMI"
}

variable "web-type" {
  default     = "t2.micro"
  description = "EC2 type"
}


