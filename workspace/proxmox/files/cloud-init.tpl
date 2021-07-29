#cloud-config
users:
  - default
  - name: ubuntu
    shell: /bin/bash
    home: /home/ubuntu
    lock_passwd: true
    groups: sudo, users, admin
    sudo: ALL=(ALL) NOPASSWD:ALL
ssh_deletekeys: true
write_files:
  - path: /etc/ssh/trusted-user-ca-keys.pem
    content: |
      ${ssh_ca_pub_key}
bootcmd:
  - cloud-init-per once ssh-users-ca echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem" >> /etc/ssh/sshd_config
package_update: true
package_upgrade: true
hostname: ${host_name}
power_state:
  timeout: 30
  mode: reboot
  message: Restarting