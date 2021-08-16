variable "vm_name" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "cifs_config" {
  type = string
}

variable "traefik_version" {
  type = string
}

variable "consul_version" {
  type = string
}

variable "ip" {
  type = string
}

variable "gateway" {
  type = string
}

variable "ssh_ca_cert" {
  type      = string
  sensitive = true
}

variable "ca_cert" {
  type      = string
  sensitive = true
}

variable "cert" {
  type      = string
  sensitive = true
}

variable "key" {
  type      = string
  sensitive = true
}

variable "encrypt_key" {
  type      = string
  sensitive = true
}

variable "server_ip_list" {
  type = list(string)
}

variable "keepalive_virtual_ip" {
  type = string
}

variable "keepalive_router_id" {
  type = number
}

variable "keepalive_state" {
  type = string
}

variable "keepalive_password" {
  type = string
}
