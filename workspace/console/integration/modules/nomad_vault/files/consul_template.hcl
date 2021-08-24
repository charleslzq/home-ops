template {
  # This is the source file on disk to use as the input template. This is often
  # called the "consul-template template".
  source      = "/opt/nomad/templates/agent.crt.tpl"

  # This is the destination path on disk where the source template will render.
  # If the parent directories do not exist, consul-template will attempt to
  # create them, unless create_dest_dirs is false.
  destination = "/opt/nomad/agent-certs/agent.crt"

  # This is the permission to render the file. If this option is left
  # unspecified, consul-template will attempt to match the permissions of the
  # file that already exists at the destination path. If no file exists at that
  # path, the permissions are 0644.
  perms       = 0755

  # This is the optional command to run when the template is rendered. The
  # command will only run if the resulting template changes.
//  command     = "systemctl reload nomad"
}

template {
  source      = "/opt/nomad/templates/agent.key.tpl"
  destination = "/opt/nomad/agent-certs/agent.key"
  perms       = 0755
}

template {
  source      = "/opt/nomad/templates/ca.crt.tpl"
  destination = "/opt/nomad/agent-certs/ca.crt"
  perms       = 0755
}