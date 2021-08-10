module "local_vault" {
  source = "./vault"
}

module "proxmox" {
  source = "./proxmox"

  depends_on = [
    module.local_vault
  ]

  ssh_ca_cert = module.local_vault.ssh_ca_cert
}