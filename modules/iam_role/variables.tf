variable "resource_prefix" {
  description = "リソース名につける識別用プレフィックス"
  type        = string
}

variable "usage_name" {
  description = "リソース名に含める用途名"
  type        = string
}

variable "policy" {
  description = "IAMポリシー"
  type        = string
}

variable "identifier" {
  description = "ロールを適応させたいIAMリソース識別子(例: codebuild.amazonaws.com)"
  type        = string
}