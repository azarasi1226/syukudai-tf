variable "resource_prefix" {
  type        = string
}

variable "usage_name" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "port" {
  type        = number
}

variable "cidr_blocks" {
  type        = list(string)
}