job "haruka" {
  datacenters = ["roger"]
  type = "service"

  group "heimdall" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "haruka"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.haruka.middlewares=yashin",
      ]
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "60s"
        timeout  = "20s"

        check_restart {
          limit = 3
          grace = "240s"
        }
      }
    }

    task "server" {
      driver = "docker"

      config {
        image   = "linuxserver/heimdall"
        ports   = ["http"]
        volumes = [
          "/opt/nomad/volume/haruka/data:/config",
        ]
      }

      env {
        PGID = 1000
        PUID = 1000
        TZ = "Asia/Shanghai"
        APP_NAME = "Haruka"
        APP_URL = "https://haruka.zenq.me"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
