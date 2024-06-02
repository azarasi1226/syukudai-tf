resource "aws_vpc" "this" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "HW-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "HW-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "ap-northeast-1c"

  map_public_ip_on_launch = true
  tags = {
    Name = "HW-public-subnet-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}






resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "ap-northeast-1a"

  map_public_ip_on_launch = false
  tags = {
    Name = "HW-private-subnet-1"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "HW-internet-gateway"
  }
}





resource "aws_instance" "private_ec2" {
  ami                    = "ami-02a405b3302affc24"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.private_ec2_security_group.id]
  tags = {
    Name = "HW-private-ec2"
  }
}
resource "aws_security_group" "private_ec2_security_group" {
  name   = "private_ec2_security_group"
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "private_allow_ssh" {
  security_group_id = aws_security_group.private_ec2_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}



resource "aws_instance" "jump_ec2" {
  ami                    = "ami-02a405b3302affc24"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.jump_security_group.id]
  tags = {
    Name = "HW-ec2"
  }
}
resource "aws_security_group" "jump_security_group" {
  name   = "jump_ec2_security_group"
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "jump_allow_ssh" {
  security_group_id = aws_security_group.jump_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_lb" "this" {
  name               = "HW-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  tags = {
    Name = "HW-alb"
  }
}

resource "aws_security_group" "alb" {
  name   = "alb_security_group"
  vpc_id = aws_vpc.this.id
}


resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  /*from_port = 0
	to_port = 0*/
  ip_protocol = "-1"
}

resource "aws_alb_target_group" "this" {
  name     = "HW-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_target_group_attachment" "this" {
  target_group_arn = aws_alb_target_group.this.arn
  target_id        = aws_instance.private_ec2.id
  port             = 80
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  /*
ssl_policy        = "ELBSecurityPolicy-2015-05"
certificate_arn   = "${var.alb_config["certificate_arn"]}"
*/
  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type             = "forward"
  }
}


resource "aws_eip" "this" {
  vpc = true
}

resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.this.id
}