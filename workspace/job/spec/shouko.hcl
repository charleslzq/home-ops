job "shouko" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "keycloak" {
    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
    }

    service {
      name = "shouko"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-shouko"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "server" {
      driver = "docker"

      env {
        DB_VENDOR = "postgres"
        DB_ADDR = "localhost"
        DB_PORT = 5432
        DB_USER = "shouko"
        DB_DATABASE = "shouko"
        KEYCLOAK_USER = "charleslzq"
        PROXY_ADDRESS_FORWARDING = true
        # KEYCLOAK_LOGLEVEL: DEBUG
      }

      config {
        image = "jboss/keycloak:latest"
        ports = ["http"]
      }

      template {
        data = <<EOH
DB_PASSWORD="{{with secret "database/data/shouko"}}{{.Data.data.password}}{{end}}"
KEYCLOAK_PASSWORD="{{with secret "database/data/shouko"}}{{.Data.data.adminPassword}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu    = 300
        memory = 500
      }
    }
  }

  group "shouko-db" {
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
      name = "db-shouko"
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
          "/opt/nomad/volume/shouko/db:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "shouko"
        POSTGRES_DB = "shouko"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/shouko"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }
}
