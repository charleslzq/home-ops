#cloud-config
apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu hirsute stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - docker-ce
  - docker-ce-cli
  - containerd.io
write_files:
  - path: /etc/pihole.d/pihole.conf
    content: |
      ${pihole_conf}
  - path: /etc/pihole.d/pihole.env
    content: |
      ${pihole_env}
runcmd:
  - sudo systemctl start docker
  - sudo systemctl enable docker
  - sudo addgroup ubuntu docker
  - sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
  - sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
  - sudo systemctl restart systemd-resolved
  - sudo docker run --restart unless-stopped --name=pihole -v pihole:/etc/pihole -v dnsmasq:/etc/dnsmasq.d -v /etc/pihole.d/pihole.conf:/etc/unbound/unbound.conf.d/pihole.conf -p "443:443" -p "80:80" -p "53:53" -p "53:53/udp" --env-file /etc/pihole.d/pihole.env -d cbcrowe/pihole-unbound:latest
