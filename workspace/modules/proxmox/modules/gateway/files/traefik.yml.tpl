global:
  checkNewVersion: true
  sendAnonymousUsage: false

log:
  level: INFO
  format: common

api:
  dashboard: true
  insecure: true

ping: {}

providers:
  consulCatalog:
    requireConsistent: true
    exposedByDefault: false
    defaultRule: "Host(`{{ .Name }}.zenq.me`)"
    endpoint:
      token: ${consul_token}
  file:
    watch: true
    directory: "/etc/traefik.d"
    debugLogGeneratedTemplate: true

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"