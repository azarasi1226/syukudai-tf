resource "aws_subnet" "private" {
    count = local.az_count

	vpc_id = aws_vpc.this.id
	cidr_block = var.private_subnet_cidrs[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index]

	tags = {
		Name = "${var.resource_prefix}-private-subnet-${count.index}"
	}
}

resource "aws_route_table" "private" {
	vpc_id = aws_vpc.this.id
	
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.this.id
	}
}

resource "aws_route_table_association" "private" {
	count  = local.az_count

	subnet_id      = aws_subnet.private[count.index].id
	route_table_id = aws_route_table.private.id
}
