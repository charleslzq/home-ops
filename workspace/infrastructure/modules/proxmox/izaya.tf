locals {
  monitors = [{
    ip   = "10.10.30.125"
    name = "izaya"
  }]
}

module "izaya" {
  count  = length(local.monitors)
  source = "./modules/cloud_init"

  vm_name         = local.monitors[count.index].name
  cloud_ip_config = "ip=${local.monitors[count.index].ip}/24,gw=${local.gateway}"
  proxmox_node    = "avalon"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content      = module.cifs.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  sockets = "2"
  memory  = 4096
}
