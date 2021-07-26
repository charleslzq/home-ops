data "vault_generic_secret" "aws_credentials" {
  path = "secret/home/aws"
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = data.vault_generic_secret.aws_credentials.data.access_key_id
  secret_key = data.vault_generic_secret.aws_credentials.data.access_key_secret
}

data "consul_keys" "aws" {
  key {
    name = "ami_id"
    path = "home/aws/env/tf_var_latest_aws_ami_id"
  }
}

resource "tls_private_key" "aws-2021" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws-2021-key" {
  key_name   = "aws.2021"
  public_key = tls_private_key.aws-2021.public_key_openssh
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
  ami           = data.consul_keys.aws.var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.aws-2021-key.key_name
  vpc_security_group_ids = [
    aws_security_group.default_group.id
  ]
}
