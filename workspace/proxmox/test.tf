data "consul_keys" "proxmox" {
  key {
    name = "consul_mac"
    path = "proxmox/consul-mac"
  }
}

data "vault_generic_secret" "default" {
  path = "secret/home/default"
}

resource "proxmox_vm_qemu" "test" {
  name                    = "VM-test"
  target_node             = "avalon"
  clone                   = "ubuntu-cloudinit"
  os_type                 = "cloud-init"
  ciuser                  = "ubuntu"
  cipassword              = data.vault_generic_secret.default.data.password
  cicustom                = "user=images:snippets/cloud-init.yml"
  cloudinit_cdrom_storage = "local-zfs"

  cores    = 1
  sockets  = "1"
  cpu      = "host"
  memory   = 1024
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    size     = "20G"
    type     = "scsi"
    storage  = "local-zfs"
    iothread = 1
  }
  network {
    model   = "virtio"
    bridge  = "vmbr0"
    macaddr = data.consul_keys.proxmox.var.consul_mac
  }
}


