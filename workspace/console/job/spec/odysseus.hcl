job "odysseus" {
  datacenters = ["roger"]
  type = "service"

  group "joplin" {
    network {
      port "http" {
        to = 22300
      }
    }

    service {
      name = "odysseus"
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

    task "server" {
      driver = "docker"

      env {
        APP_BASE_URL = "https://odysseus.zenq.me"
      }

      config {
        image = "joplin/server:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
