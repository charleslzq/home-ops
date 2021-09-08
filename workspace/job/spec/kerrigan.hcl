job "kerrigan" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "drone" {
    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2d"
    }

    service {
      name = "kerrigan"
      tags = ["traefik.enable=true"]
      port = "http"
    }

    task "drone-server" {
      driver = "docker"

      config {
        image = "drone/drone"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/kerrigan/data:/data"
        ]
      }

      env {
        DRONE_GITEA_SERVER = "https://darjeeling.zenq.me"
        DRONE_SERVER_HOST = "kerrigan.zenq.me"
        DRONE_SERVER_PROTO = "https"
        DRONE_TLS_AUTOCERT = false
        DRONE_AGENTS_ENABLED = true
      }

      template {
        data = <<EOH
DRONE_GITEA_CLIENT_ID={{with secret "oidc/darjeeling/data/kerrigan"}}{{.Data.data.id}}{{end}}
DRONE_GITEA_CLIENT_SECRET={{with secret "oidc/darjeeling/data/kerrigan"}}{{.Data.data.secret}}{{end}}
DRONE_RPC_SECRET={{with secret "home/data/kerrigan"}}{{.Data.data.secret}}{{end}}
EOH
        destination = "secrets/oidc.env"
        env         = true
      }

      resources {
        cpu = 500
        memory = 300
      }
    }
  }

  group "drone-runner" {
    count = 2

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      mode = "bridge"
      port "http" {
        to = 3000
      }
    }

    task "drone-runner" {
      driver = "docker"

      config {
        image = "drone/drone-runner-docker"
        ports = ["http"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ]
      }

      env {
        DRONE_RPC_HOST = "kerrigan.zenq.me"
        DRONE_RPC_PROTO = "https"
        DRONE_RUNNER_CAPACITY = 2
        DRONE_RUNNER_NAME = "$${attr.unique.hostname}"
      }

      template {
        data = <<EOH
DRONE_RPC_SECRET={{with secret "home/data/kerrigan"}}{{.Data.data.secret}}{{end}}
EOH
        destination = "secrets/drone.env"
        env         = true
      }

      resources {
        cpu = 300
        memory = 500
      }
    }
  }
}
