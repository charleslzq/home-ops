

data "vault_generic_secret" "consul_setting" {
  path = "home/consul/"
}

locals {
  all = concat(var.consul_clients, var.consul_servers)
  gossip_hcl = templatefile("${path.module}/files/gossip.hcl", {
    encrypt = data.vault_generic_secret.consul_setting.data.gossip
  })
}

resource "null_resource" "consul_gossip" {
  count = length(local.all)
  triggers = {
    gossip_config = local.gossip_hcl
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.all[count.index].ip
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = local.gossip_hcl
    destination = "~/10.gossip.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/10.gossip.hcl /etc/consul.d/",
      "sudo systemctl restart consul",
    ]
  }
}
