[Interface]
Address = ${address}
PrivateKey = ${private_key}
%{ if dns != "" }DNS = ${dns}%{ endif }
%{ if post_up != "" }PostUp = ${post_up}%{ endif }
%{ if post_down != "" }PostDown = ${post_down}%{ endif }
%{ if listen_port != 0 }ListenPort = ${listen_port}%{ endif }

%{ for peer in peers }
[Peer]
PublicKey = ${peer.public_key}
AllowedIPs = ${peer.allowed_ips}
%{ if peer.endpoint != "" }Endpoint = ${peer.endpoint}%{ endif }
%{ if peer.keep_alive != 0 }PersistentKeepalive = ${peer.keep_alive}%{ endif}

%{ endfor }
