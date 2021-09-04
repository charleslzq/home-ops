job "shanks" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "nextcloud" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "shanks"
    }

    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }

    service {
      name = "shanks"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-shanks"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      env {
        POSTGRES_USER = "shanks"
        POSTGRES_DB = "shanks"
        OVERWRITEPROTOCOL = "https"
      }

      config {
        image = "nextcloud:latest"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/shanks/data:/var/www/html",
        ]
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/shanks"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }

  group "nextcloud-db" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "shanks"
    }

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    service {
      name = "db-shanks"
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
          "/opt/nomad/volume/db/shanks:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "shanks"
        POSTGRES_DB = "shanks"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/shanks"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }
}
