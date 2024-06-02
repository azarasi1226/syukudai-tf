locals {
  resource_name = "${var.resource_prefix}-${var.usage_name}"
}

resource "aws_security_group" "this" {
  name   = "${local.resource_name}-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${local.resource_name}-sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.allow_port
  to_port           = var.allow_port
  protocol          = "tcp"
  cidr_blocks       = var.allow_cidrs
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}