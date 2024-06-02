resource "aws_subnet" "management" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.management_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_prefix}-management-subnet"
  }
}

resource "aws_route_table" "management" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "management" {
  route_table_id = aws_route_table.management.id
  subnet_id      = aws_subnet.management.id
}