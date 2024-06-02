locals {
  export_path = "../../export"
}

module "ssh_sg" {
  source = "../../modules/security_group"

  resource_prefix = var.resource_prefix
  usage_name      = "jump_server"
  vpc_id          = var.vpc_id
  allow_port      = "22"
  allow_cidrs     = ["0.0.0.0/0"]
}

# memo: ここをlatestにすると、user-dataが使えなくなる可能性があるのでバージョンは固定したほうがよさそう
data "aws_ssm_parameter" "this" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "jump-server-key2"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${local.export_path}/jump-server-key.pem"
  content         = tls_private_key.this.private_key_pem
  file_permission = "600"
}

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

resource "local_file" "example_command" {
  filename = "${local.export_path}/ssh-hint.txt"
  content  = "ssh -i jump-server-key.pem ec2-user@${aws_instance.this.public_dns}"
}