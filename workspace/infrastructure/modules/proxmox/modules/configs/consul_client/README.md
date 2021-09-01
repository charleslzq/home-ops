# Config Consul Client Module

Generate cloud-init config for consul cliient

## Input

name | type | description
--- | --- | ---
consul_version | string | the version of consul
consul_template_version | string | the version of consul-template
ip | string | the ip of vm
server_ip_list | list(string) | the list of ips of all consul servers

## Output

output | type | description
--- | ---| ---
cloud_init_config | string | cloud init config content, should be merge with other cloud init configs
