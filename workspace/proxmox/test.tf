data "consul_keys" "proxmox" {
  key {
    name = "consul_mac"
    path = "proxmox/consul-mac"
  }
  key {
    name = "iso_path"
    path = "images/proxmox/ubuntu_path"
  }
}

resource "proxmox_vm_qemu" "test" {
  name        = "VM-test"
  target_node = "avalon"
  iso         = data.consul_keys.proxmox.var.iso_path
  os_type     = "ubuntu"

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


