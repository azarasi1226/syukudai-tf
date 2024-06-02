variable "resource_prefix" {
  description = "リソース名につける識別用プレフィックス"
  type        = string
}

variable "usage_name" {
  description = "リソース名に含める用途名"
  type        = string
}

variable "vpc_id" {
  description = "VPC_ID"
  type        = string
}

variable "port" {
  description = "接続を許可するポート番号"
  type        = number
}

variable "cidr_blocks" {
  description = "接続を許可するIPアドレスリスト"
  type        = list(string)
}