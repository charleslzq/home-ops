locals {
  proxmox_node   = "avalon"
  vm_name        = "consul-server"
  consul_version = "1.10.1"
}

data "vault_generic_secret" "proxmox_node_settings" {
  path = "secret/home/proxmox/${local.proxmox_node}"
}

data "vault_generic_secret" "ssh_ca" {
  path = "vm-client-signer/config/ca"
}

resource "vault_pki_secret_backend" "consul" {
  path                      = "consul"
  default_lease_ttl_seconds = 3600 * 86000
  max_lease_ttl_seconds     = 3600 * 86400
}

resource "vault_pki_secret_backend_root_cert" "consul" {
  depends_on = [vault_pki_secret_backend.consul]

  backend = vault_pki_secret_backend.consul.path

  type                 = "internal"
  common_name          = "Root Consul CA"
  ttl                  = 3600 * 85000
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My Home"
}

resource "vault_pki_secret_backend_role" "consul" {
  backend          = vault_pki_secret_backend.consul.path
  name             = "consul"
  ttl              = 3600 * 84000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["zenq.me"]
  allow_subdomains = true
  generate_lease   = true
}

resource "vault_pki_secret_backend_cert" "consul" {
  depends_on = [vault_pki_secret_backend_role.consul]

  backend = vault_pki_secret_backend.consul.path
  name    = vault_pki_secret_backend_role.consul.name

  common_name = "rayleigh.zenq.me"
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
      ssh_ca_pub_key = data.vault_generic_secret.ssh_ca.data.public_key
      host_name      = local.vm_name
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/consul-init.yml.tpl", {
      consul_version = local.consul_version
      consul_ca      = indent(6, vault_pki_secret_backend_cert.consul.issuing_ca)
      consul_cert    = indent(6, vault_pki_secret_backend_cert.consul.certificate)
      consul_key     = indent(6, vault_pki_secret_backend_cert.consul.private_key)
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }
}

resource "null_resource" "cloud_init_config_files" {
  triggers = {
    file_content = data.cloudinit_config.config.rendered
  }
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.proxmox_node_settings.data.username
    password = data.vault_generic_secret.proxmox_node_settings.data.password
    host     = data.vault_generic_secret.proxmox_node_settings.data.host
  }
  provisioner "file" {
    content     = data.cloudinit_config.config.rendered
    destination = "/mnt/pve/images/snippets/cloud-init-${local.vm_name}.yml"
  }
}

resource "proxmox_vm_qemu" "consul-server" {
  name                      = local.vm_name
  target_node               = local.proxmox_node
  onboot                    = true
  clone                     = "ubuntu-cloudinit"
  os_type                   = "cloud-init"
  cicustom                  = "user=images:snippets/cloud-init-${local.vm_name}.yml"
  cloudinit_cdrom_storage   = "local-zfs"
  ipconfig0                 = "ip=10.10.30.99/24,gw=10.10.30.1"
  guest_agent_ready_timeout = 120

  cores    = 1
  sockets  = "1"
  cpu      = "host"
  memory   = 1024
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    size     = "20G"
    type     = "scsi"
    storage  = data.vault_generic_secret.proxmox_node_settings.data.storage
    iothread = 1
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}


