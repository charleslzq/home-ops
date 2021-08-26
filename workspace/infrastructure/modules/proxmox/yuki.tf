locals {
  vaults = [
    {
      ip           = "10.10.30.121"
      proxmox_node = "avalon"
      state        = "MASTER"
    },
    {
      ip           = "10.10.30.122"
      proxmox_node = "skypiea"
      state        = "BACKUP"
    }
  ]
}

resource "vault_pki_secret_backend" "pki" {
  path                  = "pki"
  max_lease_ttl_seconds = 87600 * 3600
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on = [
    vault_pki_secret_backend.pki
  ]
  backend = vault_pki_secret_backend.pki.path

  type        = "internal"
  common_name = "Root PKI CA"
  ttl         = 87600 * 3600
}

resource "vault_pki_secret_backend" "pki_int" {
  path                  = "pki_int"
  max_lease_ttl_seconds = 43800 * 3600
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on = [
    vault_pki_secret_backend.pki_int
  ]
  backend = vault_pki_secret_backend.pki_int.path

  type        = "internal"
  common_name = "Intermediate PKI"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  depends_on = [
    vault_pki_secret_backend_root_cert.root,
    vault_pki_secret_backend_intermediate_cert_request.intermediate
  ]
  backend = vault_pki_secret_backend.pki.path

  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  ttl         = 43800 * 3600
  common_name = "Intermediate CA"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  depends_on = [
    vault_pki_secret_backend_intermediate_cert_request.intermediate
  ]

  backend     = vault_pki_secret_backend.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_cert" "vault" {
  depends_on = [vault_pki_secret_backend_role.vault]

  backend     = vault_pki_secret_backend.pki_int.path
  name        = vault_pki_secret_backend_role.vault.name
  common_name = "vault"
  format      = "pem"
  ttl         = 365 * 24 * 3600
  alt_names = [
    "localhost",
    "yuki-1",
    "yuki-2"
  ]
  ip_sans = [
    "127.0.0.1",
    "10.10.30.120",
    "10.10.30.121",
    "10.10.30.122",
  ]
}

module "vault_consul_config" {
  count = length(local.vaults)

  source                  = "./modules/configs/consul_client"
  consul_version          = local.consul_version
  consul_template_version = local.consul_template_version
  ip                      = local.vaults[count.index].ip
  server_ip_list          = local.consul_server_ip_list
}

module "vault_config" {
  count  = length(local.vaults)
  source = "./modules/configs/vault"

  vault_version = local.vault_version
  ip            = local.vaults[count.index].ip
  vault_cert    = vault_pki_secret_backend_cert.vault.certificate
  vault_key     = vault_pki_secret_backend_cert.vault.private_key
  vault_ca      = vault_pki_secret_backend_cert.vault.issuing_ca
}

module "vault_keepalived_config" {
  count  = length(local.vaults)
  source = "./modules/configs/keepalived"

  ip        = "10.10.30.120"
  router_id = "120"
  password  = data.vault_generic_secret.keepalived_passwords.data.yuki
  state     = local.vaults[count.index].state
}

resource "vault_pki_secret_backend_role" "vault" {
  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.intermediate
  ]
  backend        = vault_pki_secret_backend.pki_int.path
  name           = "vault"
  ttl            = 43800 * 3600
  require_cn     = false
  generate_lease = true
  allow_any_name = true
  allow_ip_sans  = true
}


module "yuki" {
  depends_on = [
    module.rayleigh
  ]
  count = length(local.vaults)

  source          = "./modules/cloud_init"
  vm_name         = "yuki-${count.index + 1}"
  proxmox_node    = local.vaults[count.index].proxmox_node
  cloud_ip_config = "ip=${local.vaults[count.index].ip}/24,gw=10.10.30.1"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content      = module.cifs.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.vault_consul_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.vault_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.vault_keepalived_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  disk_size = "5G"
}

resource "local_file" "local_ca" {
  filename = "${path.module}/generated/ca.crt"
  content  = vault_pki_secret_backend_cert.vault.issuing_ca

  provisioner "local-exec" {
    command = "sudo mkdir -p /usr/local/share/ca-certificates/extra/"
  }
  provisioner "local-exec" {
    command = "sudo mv ${path.module}/generated/ca.crt /usr/local/share/ca-certificates/extra/"
  }
  provisioner "local-exec" {
    command = "sudo update-ca-certificates"
  }
}

locals {
  require_ca = concat(
    local.vaults.*.ip,
    local.joker_nodes.*.ip,
    local.consul_servers.*.ip,
    local.nomad_servers.*.ip,
    local.classes.*.ip
  )
}

resource "null_resource" "server_ca" {
  count = length(local.require_ca)
  triggers = {
    ca = vault_pki_secret_backend_cert.vault.issuing_ca
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.require_ca[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.vault.issuing_ca
    destination = "~/ca.crt"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /usr/local/share/ca-certificates/extra/",
      "sudo mv ~/ca.crt /usr/local/share/ca-certificates/extra/",
      "sudo update-ca-certificates",
    ]
  }
}
