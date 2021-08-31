job "kuma" {
  datacenters = ["roger"]
  type = "service"

  group "bookstack" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value = "2d"
    }

    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
      port "db" {
        to = 3306
      }
    }

    service {
      name = "kuma"
      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true"
      ]
      port = "http"

      connect {
        sidecar_service {}
      }
    }

    vault {
      policies = ["${policy}"]
    }

    task "db" {
      driver = "docker"

      service {
        name = "db-kuma"

        port = "db"

        check {
          type = "tcp"
          port = "db"
          interval = "10s"
          timeout = "2s"
        }
      }

      config {
        image = "linuxserver/mariadb"
        ports = ["db"]
        volumes = [
          "/opt/nomad/volume/db/kuma:/config",
        ]
      }

      env {
        PUID = 1000
        PGID = 1000
        TZ = "Asia/Shanghai"
        MYSQL_DATABASE = "kuma"
        MYSQL_USER = "kuma"
      }

      template {
        data = <<EOH
MYSQL_PASSWORD="{{with secret "database/data/kuma"}}{{.Data.data.password}}{{end}}"
MYSQL_ROOT_PASSWORD="{{with secret "database/data/kuma"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env = true
      }
    }

    task "server" {
      driver = "docker"

      env {
        PUID = 1000
        PGID = 1000
        APP_URL = "https://kuma.zenq.me"
        DB_HOST = "$${NOMAD_IP_db}"
        DB_PORT = "$${NOMAD_HOST_PORT_db}"
        DB_USER = "kuma"
        DB_DATABASE = "kuma"
      }

      config {
        image = "linuxserver/bookstack"
        ports = ["http"]
      }

      template {
        data = <<EOH
DB_PASS="{{with secret "database/data/kuma"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env = true
      }
    }
  }
}
