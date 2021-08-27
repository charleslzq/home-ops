job "tosaka" {
  datacenters = ["roger"]
  type = "system"

  group "pihole" {
    constraint {
      attribute = "$${meta.node_type}"
      value     = "dns"
    }

    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "dns" {
        static = 53
      }
    }

    vault {
      policies = ["${policy}"]
    }

    //sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
    //sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
    //sudo systemctl restart systemd-resolved
    task "server" {
      driver = "docker"

      service {
        name = "tosaka"
        port = "http"

        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }

      config {
        image = "pihole/pihole:latest"
        network_mode = "host"
        volumes = [
          "local/pihole.conf:/etc/unbound/unbound.conf.d/pihole.conf",
          "local/dnsmasq.conf:/etc/dnsmasq.d/pihole.conf",
          "/opt/nomad/volume/tosaka/pihole:/etc/pihole",
          "/opt/nomad/volume/tosaka/dnsmasq:/etc/dnsmasq.d",
        ]
      }

      env {
        ServerIP="$${NOMAD_IP_http}"
        TZ="Asia/Shanghai"
        REV_SERVER=false
        REV_SERVER_DOMAIN="local"
        REV_SERVER_TARGET="192.168.1.1"
        REV_SERVER_CIDR="192.168.0.0/16"
        HOSTNAME="$${attr.unique.hostname}"
        DOMAIN_NAME="tosaka.zenq.me"
        VIRTUAL_HOST="tosaka.zenq.me"
        DNS1="127.0.0.1#5335"
        DNS2="127.0.0.1#5335"
        DNSSEC=true
      }

      template {
        data = <<EOH
WEBPASSWORD="{{with secret "home/data/default"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/server.env"
        env = true
      }

      template {
        data = <<EOH
address=/zenq.me/10.10.30.110
address=/.zenq.me/10.10.30.110
EOH
        destination = "local/dnsmasq.conf"
      }

      template {
        data = <<EOH
# Config pulled from https://docs.pi-hole.net/guides/unbound/

server:
    # If no logfile is specified, syslog is used
    # logfile: "/var/log/unbound/unbound.log"
    verbosity: 0

    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    # May be set to yes if you have IPv6 connectivity
    do-ip6: no

    # You want to leave this to no unless you have *native* IPv6. With 6to4 and
    # Terredo tunnels your web browser should favor IPv4 for the same reasons
    prefer-ip6: no

    # Use this only when you downloaded the list of primary root servers!
    # If you use the default dns-root-data package, unbound will find it automatically
    #root-hints: "/var/lib/unbound/root.hints"

    # Trust glue only if it is within the server's authority
    harden-glue: yes

    # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
    harden-dnssec-stripped: yes

    # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
    # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
    use-caps-for-id: no

    # Reduce EDNS reassembly buffer size.
    # Suggested by the unbound man page to reduce fragmentation reassembly problems
    edns-buffer-size: 1472

    # Perform prefetching of close to expired message cache entries
    # This only applies to domains that have been frequently queried
    prefetch: yes

    # One thread should be sufficient, can be increased on beefy machines. In reality for most users running on small networks or on a single machine, it should be unnecessary to seek performance enhancement by increasing num-threads above 1.
    num-threads: 1

    # Ensure kernel buffer is large enough to not lose messages in traffic spikes
    so-rcvbuf: 1m

    # Ensure privacy of local IP ranges
    private-address: 10.10.10.0/24
    private-address: 10.10.30.0/24
    domain-insecure: "zenq.me"
    local-zone: "zenq.me" redirect
    local-data: "zenq.me A 10.10.30.110"
    forward-zone:
        name: "."
        forward-addr: 1.1.1.1
        forward-addr: 8.8.8.8
EOH
        destination = "local/pihole.conf"
      }
    }
  }
}
