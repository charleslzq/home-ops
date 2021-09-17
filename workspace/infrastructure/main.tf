module "local_vault" {
  source = "./modules/vault"
}

module "proxmox" {
  source = "./modules/proxmox"

  depends_on = [
    module.local_vault
  ]

  ssh_ca_cert = module.local_vault.ssh_ca_cert
}

resource "local_file" "ansible_hosts" {
  filename = "${path.module}/../generated/hosts"
  content = templatefile("${path.module}/ansible_hosts.tpl", {
    vaults         = module.proxmox.vaults
    nomad_servers  = module.proxmox.nomad_servers
    consul_servers = module.proxmox.consul_servers
    dns_servers    = module.proxmox.dns_servers
    gateways       = module.proxmox.gateways
    nas_servers    = module.proxmox.nas
    workers        = module.proxmox.workers
    relays         = module.proxmox.relays
    monitors       = module.proxmox.monitors
  })
}
