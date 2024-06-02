variable "resource_prefix" {
  type = string
}

variable "usage_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allow_port" {
  type = number
}

variable "allow_cidrs" {
  type = list(string)
}