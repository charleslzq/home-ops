# Config Keepalived Module

Generate cloud-init config for keepalived

## Input

name | type | default | description
--- | --- | --- | ---
state | string | | the state of keepalived, "MASTER" or "BACKUP"
interface | string | "eth0" | the interface to use
router_id | number | | the router id, should be unique in lan
priority | number | 100 | 
advert_int | number | 1 | 
password | string | | the password of keepalived
ip | string | the ip of keepalived

## Output

output | type | description
--- | ---| ---
cloud_init_config | string | cloud init config content, should be merge with other cloud init configs