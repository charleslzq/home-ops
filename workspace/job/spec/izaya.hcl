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

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "loki"
              local_bind_port  = 3100
            }
          }
        }
      }
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

  group "loki" {
    network {
      mode = "bridge"
      port "http" {
        to = 3100
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    service {
      name = "loki"
      port = "http"
      address_mode = "alloc"

      connect {
        sidecar_service {}
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki:master"
        ports = ["http"]
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }
  }
}
