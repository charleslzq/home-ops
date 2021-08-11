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