locals {
  consul_version = "1.10.1"
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
      ssh_ca_pub_key = data.vault_generic_secret.ssh_ca.data.public_key
      host_name      = "consul-server-1"
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/consul-init.yml.tpl", {
      consul_version = local.consul_version
      consul_ca      = indent(6, vault_pki_secret_backend_cert.consul.issuing_ca)
      consul_cert    = indent(6, vault_pki_secret_backend_cert.consul.certificate)
      consul_key     = indent(6, vault_pki_secret_backend_cert.consul.private_key)
      consul_config = indent(6, templatefile("${path.module}/files/consul.hcl.tpl", {
        encrypt_key = jsonencode(data.vault_generic_secret.consul_config.data.encrypt-key)
      }))
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }
}

module "consul-cluster" {
  source = "./cloud_init"

  vm_name            = "consul-server-1"
  proxmox_node       = "skypiea"
  cloud_init_content = data.cloudinit_config.config.rendered
  cloud_ip_config    = "ip=10.10.30.99/24,gw=10.10.30.1"
}
