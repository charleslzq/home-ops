job "mashu" {
  datacenters = ["roger"]
  type = "service"

  group "vaultwarden" {
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

      env {
        APP_BASE_URL = "https://odysseus.zenq.me"
      }

      config {
        image = "vaultwarden/server:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
