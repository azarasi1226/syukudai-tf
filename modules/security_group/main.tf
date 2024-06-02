locals {
  resource_name = "${var.resource_prefix}-${var.usage_name}"
}

# セキュリティグループ
resource "aws_security_group" "this" {
  name   = "${local.resource_name}-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${local.resource_name}-sg"
  }
}

# インバウンドルール
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = aws_security_group.this.id
}

# アウトバウンドルール(全通信を許可)
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}