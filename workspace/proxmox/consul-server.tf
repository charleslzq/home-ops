terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

data "vault_generic_secret" "consul_config" {
  path = "secret/home/consul"
}

module "consul_server" {
  count = 1

  source         = "./consul_server"
  vm_name        = "consul-server-${count.index + 1}"
  proxmox_node   = lookup(data.vault_generic_secret.consul_config.data, "server_${count.index + 1}_proxmox_node", "")
  consul_version = "1.10.1"
  ip             = lookup(data.vault_generic_secret.consul_config.data, "server_${count.index + 1}_ip", "")
  gateway        = data.vault_generic_secret.consul_config.data.gateway
  encrypt_key    = data.vault_generic_secret.consul_config.data.encrypt_key
  ca_cert        = data.vault_generic_secret.consul_config.data.ca_cert
  ssh_ca_cert    = var.ssh_ca_cert
  cert           = lookup(data.vault_generic_secret.consul_config.data, "server_${count.index + 1}_cert", "")
  key            = lookup(data.vault_generic_secret.consul_config.data, "server_${count.index + 1}_key", "")
  domain         = "rayleigh.zenq.me"
}
