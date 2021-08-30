variable "vault_address" {
  type = string
}

variable "vault_int_ca_path" {
  type = string
}

variable "consul_servers" {
  type = list(object({
    ip   = string
    name = string
  }))
}

variable "consul_clients" {
  type = list(object({
    ip   = string
    name = string
  }))
}

variable "vaults" {
  type = list(object({
    ip   = string
    name = string
  }))
}

locals {
  all_clients = concat(var.vaults, var.consul_clients)
}
