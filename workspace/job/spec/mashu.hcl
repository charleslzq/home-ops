job "mashu" {
  datacenters = ["roger"]
  type = "service"

  group "vaultwarden" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "1d"
    }

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "mashu"
      tags = ["traefik.enable=true"]

      port = "http"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "shield" {
      driver = "docker"

      config {
        image = "vaultwarden/server:latest"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/db/mashu:/data",
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
