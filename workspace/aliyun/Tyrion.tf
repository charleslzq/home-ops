data "vault_generic_secret" "aliyun_credentials" {
  path = "secret/home/aliyun"
}

data "vault_generic_secret" "default" {
  path = "secret/home/default"
}

data "consul_keys" "aliyun" {
  key {
    name = "image_id"
    path = "images/aliyun_image_id"
  }
}

provider "alicloud" {
  access_key = data.vault_generic_secret.aliyun_credentials.data.access_key
  secret_key = data.vault_generic_secret.aliyun_credentials.data.secret_key
  region     = "cn-shanghai"
}

resource "alicloud_vpc" "default" {
  cidr_block  = "172.19.0.0/16"
  description = "System created default VPC."
}

resource "alicloud_vswitch" "default" {
  cidr_block  = "172.19.176.0/20"
  vpc_id      = alicloud_vpc.default.id
  description = "System created default virtual switch."
}

resource "alicloud_security_group" "tyrion" {
  vpc_id = alicloud_vpc.default.id
  name   = "Tyrion"
  tags   = {}
}

resource "alicloud_security_group_rule" "allow-ssh" {
  ip_protocol       = "tcp"
  security_group_id = alicloud_security_group.tyrion.id
  type              = "ingress"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow-wg" {
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.tyrion.id
  type              = "ingress"
  policy            = "accept"
  port_range        = "46335/46335"
  priority          = 1
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "refuse-others" {
  ip_protocol       = "all"
  security_group_id = alicloud_security_group.tyrion.id
  type              = "ingress"
  policy            = "drop"
  port_range        = "-1/-1"
  priority          = 100
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow-all-out" {
  ip_protocol       = "all"
  security_group_id = alicloud_security_group.tyrion.id
  type              = "egress"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 100
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "Tyrion" {
  instance_name              = "Tyrion"
  instance_type              = "ecs.t5-lc2m1.nano"
  image_id                   = data.consul_keys.aliyun.var.image_id
  password                   = data.vault_generic_secret.default.data.password
  instance_charge_type       = "PrePaid"
  internet_max_bandwidth_out = 100
  system_disk_size           = 20
  renewal_status             = "AutoRenewal"
  vswitch_id                 = alicloud_vswitch.default.id
  security_groups = [
    alicloud_security_group.tyrion.id
  ]
  dry_run            = false
  force_delete       = false
  include_data_disks = true
}