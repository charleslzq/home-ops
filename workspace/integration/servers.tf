locals {
  vault_address = "https://10.10.30.120:8200"
  nomad_servers = [
    {
      ip   = "10.10.30.210"
      name = "roger-1"
    },
    {
      ip   = "10.10.30.211"
      name = "roger-2"
    },
    {
      ip   = "10.10.30.212"
      name = "roger-3"
    }
  ]
  nomad_clients = [
    {
      ip   = "10.10.30.50"
      name = "2c"
    },
    {
      ip   = "10.10.30.51"
      name = "2d"
    },
    {
      ip   = "10.10.30.52"
      name = "1d"
    },
    {
      ip   = "10.10.30.111"
      name = "joker-1"
    },
    {
      ip   = "10.10.30.112"
      name = "joker-2"
    },
    {
      ip   = "10.10.30.234"
      name = "rin"
    },
    {
      ip   = "10.10.30.236"
      name = "sakura"
    },
  ]
  vaults = [
    {
      ip   = "10.10.30.121"
      name = "yuki-1"
    },
    {
      ip   = "10.10.30.122"
      name = "yuki-2"
  }]
  consul_servers = [
    {
      ip   = "10.10.30.99"
      name = "rayleigh-1"
    },
    {
      ip   = "10.10.30.100"
      name = "rayleigh-2"
    },
    {
      ip   = "10.10.30.101"
      name = "rayleigh-3"
  }]
  consul_clients = concat(local.vaults, local.nomad_servers, local.nomad_clients)
  all_servers    = concat(local.consul_servers, local.consul_clients)
}
