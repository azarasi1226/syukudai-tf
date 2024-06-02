locals {
    # アベイラビリティゾーンの数
    az_count = 3
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
	enable_dns_hostnames = true

	tags = {
		Name = "${var.resource_prefix}-vpc"
    }
}

# Subnet
resource "aws_subnet" "management" {
    vpc_id = aws_vpc.this.id

    cidr_block = var.management_cidr
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.resource_prefix}-management-subnet"
    }

}

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

resource "aws_subnet" "private" {
    count = local.az_count

	vpc_id = aws_vpc.this.id
	cidr_block = var.private_subnet_cidrs[count.index]
	availability_zone = data.aws_availability_zones.available.names[count.index]

	tags = {
		Name = "${var.resource_prefix}-private-subnet-${count.index}"
	}
}

# IG
resource "aws_internet_gateway" "this"{
	vpc_id = aws_vpc.this.id

	tags = {
		Name = "${var.resource_prefix}-internet-gateway"
	}
}

# Nat gateway
resource "aws_eip" "this" {
  	domain = "vpc"

	tags = {
		Name = "${var.resource_prefix}-eip"
	}
}

resource "aws_nat_gateway" "this" {
	subnet_id     = aws_subnet.ingress[0].id
	allocation_id = aws_eip.this.id

  	tags = {
		Name = "${var.resource_prefix}-nat-gateway"
	}
}

# ingress route table
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


# management route table
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

# private route table
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
