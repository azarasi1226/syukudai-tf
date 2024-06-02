#!/bin/bash

# Git
yum update -y
yum install git -y

# docker
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user

# docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose