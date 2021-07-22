provider "vault" {
  address         = "http://127.0.0.1:8200"
  skip_tls_verify = true
}

data "vault_generic_secret" "aws_credentials" {
  path = "secret/home/aws"
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = data.vault_generic_secret.aws_credentials.data.access_key_id
  secret_key = data.vault_generic_secret.aws_credentials.data.access_key_secret
}

variable "LATEST_AWS_AMI_ID" {
  type = string
}

resource "tls_private_key" "aws-2021" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws-2021-key" {
  key_name   = "aws.2021"
  public_key = tls_private_key.aws-2021.public_key_openssh
}

resource "vault_mount" "aws" {
  type = "ssh"
  path = "home/aws"
}

resource "vault_ssh_secret_backend_ca" "aws" {
  backend              = vault_mount.aws.path
  generate_signing_key = false
  public_key           = tls_private_key.aws-2021.public_key_openssh
  private_key          = tls_private_key.aws-2021.private_key_pem
}

resource "aws_security_group" "default_group" {
  name = "default_security_group"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "JohnSnow" {
  ami           = var.LATEST_AWS_AMI_ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.aws-2021-key.key_name
  vpc_security_group_ids = [
    aws_security_group.default_group.id
  ]
}
