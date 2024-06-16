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
    type = number
}

variable "blue_targetgroup_arn" {
    type = string
}

variable "prod_listener_arn" {
  description = "本番環境のlisner arn"
  type        = string
}

variable "test_listener_arn" {
  description = "テスト環境のlisner arn"
  type        = string
}

variable "blue_targetgroup_name" {
  description = "blueTargetGroup"
  type        = string
}

variable "green_targetgroup_name" {
  description = "greenTargetGroup"
  type        = string
}
