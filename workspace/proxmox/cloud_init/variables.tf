variable "vm_name" {
  type = string
}

variable "ssh_ca_cert" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "cloud_ip_config" {
  type = string
}

variable "cloud_init_parts" {
  type = list(object({
    content_type = string
    content      = string
    merge_type   = string
  }))
}

