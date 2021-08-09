module "local_vault" {
  source = "./vault"
}

module "proxmox" {
  source = "./proxmox"

  depends_on = [
    module.local_vault
  ]
}