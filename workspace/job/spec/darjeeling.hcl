job "darjeeling" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "gitea" {
    network {
      mode = "bridge"
      port "http" {
        to = 3000
      }
    }
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "1d"
    }

    service {
      name = "darjeeling"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-darjeeling"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "gitea-server" {
      driver = "docker"

      config {
        image = "gitea/gitea"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/darjeeling/data:/data"
        ]
      }

      env {
        GITEA__database__DB_TYPE = "postgres"
        GITEA__database__HOST = "localhost:5432"
        GITEA__database__NAME = "darjeeling"
        GITEA__database__USER = "darjeeling"
        GITEA__service__DISABLE_REGISTRATION = true
      }

      template {
        data = <<EOH
GITEA__database__PASSWD={{with secret "database/data/darjeeling"}}{{.Data.data.password}}{{end}}
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 500
        memory = 300
      }
    }
  }

  group "gitea-db" {
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
      name = "db-darjeeling"
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
          "/opt/nomad/volume/mashu/db:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "darjeeling"
        POSTGRES_DB = "darjeeling"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/darjeeling"}}{{.Data.data.password}}{{end}}"
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
