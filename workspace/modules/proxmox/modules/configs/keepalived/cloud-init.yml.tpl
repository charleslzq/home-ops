packages:
  - keepalived
write_files:
  - path: /etc/keepalived/keepalived.conf
    content: |
      vrrp_instance VI_1 {
        state ${state}
        interface ${interface}
        virtual_router_id ${router_id}
        priority ${priority}
        advert_int ${advert_int}
        authentication {
          auth_type PASS
          auth_pass ${password}
        }
        virtual_ipaddress {
          ${ip}/24
        }
      }
runcmd:
  - sudo systemctl start keepalived
  - sudo systemctl enable keepalived
