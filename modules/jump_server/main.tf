# SSH Keyの保存先
locals {
  export_path = "../../export"
}

# SSH接続用セキュリティグループ
module "ssh_sg" {
  source = "../../modules/security_group"

  resource_prefix = var.resource_prefix
  usage_name      = "jump_server"
  vpc_id          = var.vpc_id
  port            = "22"
  cidr_blocks     = ["0.0.0.0/0"]
}

# amazonlinux2の最新amiを取得
data "aws_ssm_parameter" "this" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# SSH Key
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Key Pair
resource "aws_key_pair" "this" {
  key_name   = "jump-server-key2"
  public_key = tls_private_key.this.public_key_openssh
}

# ローカルにprivate Key出力
resource "local_file" "private_key" {
  filename        = "${local.export_path}/jump-server-key.pem"
  content         = tls_private_key.this.private_key_pem
  file_permission = "600"
}

# 踏み台サーバー
resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.this.value
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  user_data              = file("${path.module}/user-data.sh")
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [module.ssh_sg.security_group_id]

  tags = {
    "Name" = "${var.resource_prefix}-jump-server"
  }
}

# SSH接続しやすくするためのお助けコマンドファイル出力
resource "local_file" "example_command" {
  filename = "${local.export_path}/ssh-hint.txt"
  content  = "ssh -i jump-server-key.pem ec2-user@${aws_instance.this.public_dns}"
}