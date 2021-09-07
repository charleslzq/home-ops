job "riza" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "tinytinyrss" {
    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }

    service {
      name = "riza"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-riza"
              local_bind_port  = 5432
            }
            upstreams {
              destination_name = "mercury-riza"
              local_bind_port = 3000
            }
            upstreams {
              destination_name = "violet"
              local_bind_port = 8123
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      env {
        PGID = 1000
        PUID = 1000
        SELF_URL_PATH = "https://riza.zenq.me"
        DB_HOST = "localhost"
        DB_PORT = 5432
        DB_USER = "riza"
        DB_NAME = "riza"
        HTTP_PROXY = "127.0.0.1:8123"
      }

      config {
        image = "wangqiru/ttrss:latest"
        ports = ["http"]
      }

      template {
        data = <<EOH
DB_PASS="{{with secret "database/data/riza"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 300
        memory = 200
      }
    }
  }

  group "mercury" {
    network {
      mode = "bridge"
      port "http" {
        to = 3000
      }
    }

    service {
      name = "mercury-riza"
      port = "http"
      address_mode = "alloc"

      connect {
        sidecar_service {}
      }
    }

    task "mercury" {
      driver = "docker"

      config {
        image = "wangqiru/mercury-parser-api:latest"
        ports = ["http"]
      }

      resources {
        cpu = 100
        memory = 200
      }
    }
  }

  group "riza-db" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2d"
    }

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    service {
      name = "db-riza"
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
          "/opt/nomad/volume/riza/db:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "riza"
        POSTGRES_DB = "riza"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/riza"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 100
        memory = 50
      }
    }
  }
}
