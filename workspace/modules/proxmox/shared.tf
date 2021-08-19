module "cifs" {
  source = "./modules/configs/cifs"
}

locals {
  consul_version  = "1.10.1"
  nomad_version   = "1.1.3"
  vault_version   = "1.8.1"
  traefik_version = "2.4.13"
  gateway         = "10.10.30.1"
}

data "vault_generic_secret" "keepalived_passwords" {
  path = "secret/home/keepalived"
}
