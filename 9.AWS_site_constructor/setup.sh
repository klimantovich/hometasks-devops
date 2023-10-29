#!/bin/bash

REMOTE_IP="13.48.45.55"

ssh ec2-user@$REMOTE_IP 'sudo yum update'
ssh ec2-user@$REMOTE_IP 'sudo yum install -y httpd php8.1'
ssh ec2-user@$REMOTE_IP 'sudo yum install -y nodejs npm'

ssh ec2-user@$REMOTE_IP 'sudo dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel -y'

ssh ec2-user@$REMOTE_IP 'sudo systemctl enable httpd && sudo systemctl start httpd'
ssh ec2-user@$REMOTE_IP 'sudo systemctl enable httpd && sudo systemctl start mariadb'

