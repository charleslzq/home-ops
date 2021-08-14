module "cifs" {
  source = "./modules/configs/cifs"
}

locals {
  consul_version = "1.10.1"
  nomad_version  = "1.1.3"
  vault_version  = "1.8.1"
}
