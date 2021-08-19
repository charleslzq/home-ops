data "vault_generic_secret" "yagami_settings" {
  path = "secret/home/yagami"
}

locals {
  classes = jsondecode(nonsensitive(data.vault_generic_secret.yagami_settings.data.classes))
}

module "yagami" {
  depends_on = [
    module.rayleigh,
    module.roger
  ]
  count = length(local.classes)

  source = "./modules/worker"

  cifs_config    = module.cifs.cloud_init_config
  consul_version = local.consul_version
  nomad_version  = local.nomad_version
  server_ip_list = local.consul_server_ip_list
  gateway        = "10.10.30.1"
  ssh_ca_cert    = var.ssh_ca_cert
  vm_name        = local.classes[count.index].name
  proxmox_node   = local.classes[count.index].proxmox_node
  ip             = local.classes[count.index].ip
}
