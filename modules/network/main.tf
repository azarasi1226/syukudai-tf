locals {
  az_count = 3
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.resource_prefix}-internet-gateway"
  }
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.resource_prefix}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.management.id
  allocation_id = aws_eip.this.id

  tags = {
    Name = "${var.resource_prefix}-nat-gateway"
  }
}