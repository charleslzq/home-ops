packages:
  - cifs-utils
write_files:
  - path: /etc/wireguard/wg0.conf
    content: |
      ${wireguard_config}
bootcmd:
  - wg-quick up wg0
