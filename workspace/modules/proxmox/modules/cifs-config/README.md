# CIFS module

* provide cifs related cloud-init config with pre-defined settings

## Setting

require the following secrets in vault at path `secret/home/cifs`
name | type
--- | ---
path | string
username | stirng
password | string

## Output

output | type | description
--- | ---| ---
cloud_init_config | string | cloud init config content, should be merge with other cloud init configs
