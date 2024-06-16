variable "resource_prefix" {
  description = "リソース名につける識別用プレフィックス"
  type        = string
}

variable "vpc_id" {
  description = "VPC_ID"
  type        = string
}

variable "subnet_ids" {
  description = "コンテナを起動するサブネットのidリスト"
  type        = list(string)
}

variable "container_port" {
    type = string
}