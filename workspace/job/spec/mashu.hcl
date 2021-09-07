job "mashu" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "vaultwarden" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }

    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }

    service {
      name = "mashu"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-mashu"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "shield" {
      driver = "docker"

      config {
        image = "vaultwarden/server:latest"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/mashu:/data",
        ]
      }

      env {
        SIGNUPS_ALLOWED = false
      }

      template {
        data = <<EOH
DATABASE_URL=postgresql://mashu:{{with secret "database/data/mashu"}}{{.Data.data.password}}{{end}}@localhost:5432/mashu
ADMIN_TOKEN={{with secret "database/data/mashu"}}{{.Data.data.token}}{{end}}
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 100
        memory = 100
      }
    }
  }

  group "vaultwarden-db" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    service {
      name = "db-mashu"
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
          "/opt/nomad/volume/db/mashu:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "mashu"
        POSTGRES_DB = "mashu"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/mashu"}}{{.Data.data.password}}{{end}}"
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
