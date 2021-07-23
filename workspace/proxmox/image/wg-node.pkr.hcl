locals {
  root_password    = vault("secret/home/default", "password")
  proxmox_token_id = vault("secret/home/proxmox", "token_id")
  proxmox_secret   = vault("secret/home/proxmox", "secret")
}

source "proxmox" "wg-node" {
  proxmox_url              = "https://10.10.30.168:8006/api2/json"
  insecure_skip_tls_verify = true
  node                     = "avalon"
  pool                     = "hashi"
  username                 = local.proxmox_token_id
  token                    = local.proxmox_secret
  iso_file                 = "images:iso/alpine-standard-3.14.0-x86_64.iso"

  memory  = 512
  sockets = 1
  cores   = 1
  os      = "l26"

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"

  disks {
    type              = "scsi"
    disk_size         = "3G"
    storage_pool      = "local-zfs"
    storage_pool_type = "zfs"
    format            = "raw"
  }

  ssh_username = root
  ssh_password = local.root_password
  ssh_timeout  = "35m"

  floppy_dirs = [
    "./answers"
  ]
  shutdown_command = "/sbin/poweroff"
  boot_wait        = "15s"
  boot_command = [
    "root<enter><wait>",
    "mount -t vfat /dev/fd0 /media/floppy<enter><wait>",
    "setup-alpine -f /media/floppy/ANSWERS/wg.answerfile<enter>",
    "<wait10>",
    "${local.root_password}<enter>",
    "${local.root_password}<enter>",
    "<wait10>",
    "y<enter>",
    "<wait10><wait10><wait10><wait10>",
    "reboot<enter>",
    "<wait90>",
    "root<enter>",
    "${local.root_password}<enter><wait>",
    "mount -t vfat /dev/fd0 /media/floppy<enter><wait>",
    "/media/floppy/ANSWERS/SETUP.SH<enter>"
  ]

  onboot               = true
  umount               = true
  template_name        = "wg-node"
  template_description = "template for wireguard"
}

build {
  sources = ["source.proxmox.wg-node"]
  provisioner "file" {
    source      = "scripts"
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "ls -la /tmp",
      "cd /tmp/scripts",
      "chmod +x setup-wg.sh",
      "./setup-wg.sh",
    ]
  }
}

