job "db" {
  datacenters = ["roger"]
  type = "service"

  group "postgres" {
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
      name = "db-postgres"
      port = "db"

      connect {
        sidecar_service {}
      }
    }

    vault {
      policies = ["${policy}"]
    }

    task "db" {
      driver = "docker"

      config {
        image = "postgres:latest"
        ports = ["db"]
        volumes = [
          "/opt/nomad/volume/db/postgres:/var/lib/postgresql/data",
        ]
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/postgres"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }
}
