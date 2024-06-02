resource "aws_subnet" "ingress" {
    count = local.az_count

	vpc_id = aws_vpc.this.id
	cidr_block = var.ingress_subnet_cidrs[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index]
	map_public_ip_on_launch = true

	tags = {
		Name = "${var.resource_prefix}-ingress-subnet-${count.index}"
	}
}

resource "aws_route_table" "ingress" {
	vpc_id = aws_vpc.this.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.this.id
	}
}

resource "aws_route_table_association" "ingress" {
	count = local.az_count

	route_table_id = aws_route_table.ingress.id
	subnet_id      = aws_subnet.ingress[count.index].id
}