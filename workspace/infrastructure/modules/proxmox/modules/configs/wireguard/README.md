# Config Wireguard Module

Generate cloud-init config for wireguard.

## Input

name | type | default | description
--- | --- | --- | ---
address | string | | ip address of this node in wireguard network
private_key | string | | the private key of this wireguard node
dns | string | "" | dns for this node
post_up | string | | post up hook for wireguard network
post_down | string | | post down hook for wireguard network
listen_port | number | 0 | the listen port of this node. Will not include this entry if it's 0.
peers | list(object) | | configureation for peers

The fields of peer configuration:
name | type | description
--- | --- | ---
endpoint | string | peer address and port
public_key | string | peer public key
allowed_ips | string | ip route rules
keep_alive | number | 


## Output

output | type | description
--- | ---| ---
cloud_init_config | string | cloud init config content, should be merge with other cloud init configs
