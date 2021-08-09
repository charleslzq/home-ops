variable "vm_name" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "cloud_init_content" {
  type      = string
  sensitive = true
}

variable "cloud_ip_config" {
  type = string
}
