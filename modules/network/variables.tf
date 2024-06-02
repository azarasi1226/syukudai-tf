variable "resource_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "management_cidr" {
  type = string
}

variable "ingress_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}