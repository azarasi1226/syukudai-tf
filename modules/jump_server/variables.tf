variable "resource_prefix" {
  description = "リソース名につける識別用プレフィックス"
  type        = string
}

variable "vpc_id" {
  description = "VPC_ID"
  type        = string
}

variable "subnet_id" {
  description = "踏み台サーバーを設置するパブリックサブネットID"
  type        = string
}