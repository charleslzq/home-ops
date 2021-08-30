terraform {
  required_providers {
    consul = {}
  }
}

variable "vault_address" {
  type = string
}

variable "vault_int_ca_path" {
  type = string
}

variable "nomad_servers" {
  type = list(string)
}

variable "nomad_clients" {
  type = list(string)
}
