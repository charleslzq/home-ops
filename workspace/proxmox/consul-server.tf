terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

module "consul_server" {
  source         = "./consul_server"
  vm_name        = "consul-server-1"
  proxmox_node   = "skypiea"
  consul_version = "1.10.1"
  ip             = "10.10.30.99/24"
  gateway        = "10.10.30.1"
  domain         = "rayleigh.zenq.me"
}
