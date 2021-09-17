[consul_server]
%{ for consul_server in consul_servers }${consul_server.ip}
%{ endfor }

[vault]
%{ for vault in vaults }${vault.ip}
%{ endfor }

[nomad_server]
%{ for nomad_server in nomad_servers }${nomad_server.ip}
%{ endfor }

[gateway]
%{ for gateway in gateways }${gateway.ip}
%{ endfor }

[dns_server]
%{ for dns_server in dns_servers }${dns_server.ip}
%{ endfor }

[worker]
%{ for worker in workers }${worker.ip}
%{ endfor }

[nas]
%{ for nas in nas_servers }${nas.ip}
%{ endfor }

[relay]
%{ for relay in relays }${relay.ip}
%{ endfor }

[monitor]
%{ for monitor in monitors }${monitor.ip}
%{ endfor }

[nomad_client:children]
gateway
dns_server
worker
nas

[consul_client:children]
vault
nomad_server
nomad_client

[hashi_server:children]
consul_server
vault
nomad_server

[hashi:children]
consul_client
consul_server

[all:vars]
ansible_ssh_user=ubuntu
