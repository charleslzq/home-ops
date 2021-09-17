job "izaya" {
  datacenters = ["roger"]
  type        = "service"

  group "grafana" {
    network {
      mode = "bridge"
      port "http" {
        to = 3000
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    service {
      name = "izaya"
      tags = ["traefik.enable=true"]
      port = "http"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana"
        ports = ["http"]
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }
  }
}
