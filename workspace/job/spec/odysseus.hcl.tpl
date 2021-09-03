job "odysseus" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "joplin" {
    network {
      mode = "bridge"
      port "http" {
        to = 22300
      }
    }

    service {
      name = "odysseus"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-odysseus"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      env {
        APP_BASE_URL = "https://odysseus.zenq.me"
        DB_CLIENT= "pg"
        POSTGRES_USER = "odysseus"
        POSTGRES_DATABASE = "odysseus"
      }

      config {
        image = "joplin/server:latest"
        ports = ["http"]
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/odysseus"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }

  group "joplin-db" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "1d"
    }

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    service {
      name = "db-odysseus"
      port = "db"
      address_mode = "alloc"

      connect {
        sidecar_service {}
      }
    }

    task "db" {
      driver = "docker"

      config {
        image = "postgres:latest"
        ports = ["db"]
        volumes = [
          "/opt/nomad/volume/db/odysseus:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "odysseus"
        POSTGRES_DB = "odysseus"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/odysseus"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }
}
