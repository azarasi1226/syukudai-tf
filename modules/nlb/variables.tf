variable "resource_prefix" {
  description = "リソース名につける識別用プレフィックス"
  type        = string
}

variable "subnet_ids" {
  description = "ロードバランサーを配置したいサブネットのIDリスト"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC_ID"
  type        = string
}