output "vpc_id" {
  value = aws_vpc.this.id
}

output "management_subnet_id" {
  value = aws_subnet.management.id
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "ingress_subnet_ids" {
  value = [for subnet in aws_subnet.ingress : subnet.id]
}