terraform {
  required_version = "~> 1.8.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.52.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = var.profile

    default_tags {
        tags = {
            CreatedBy = "terraform"
            Environment  = "test"
            ProjectName = "homework"
        }
    }
}