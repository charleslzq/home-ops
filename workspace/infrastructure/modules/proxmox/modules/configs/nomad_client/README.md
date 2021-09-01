# Config Nomad Client Module

Generate cloud-init config for nomad client. Nomad client will join cluster through consul,
which is not included in this module. Will install cni packages and docker as well. Nomad binary
should be located at directory `/mnt/cifs/cloud-init/nomad/${nomad_version}/` and cni package should
be located at `/mnt/cifs/cloud-init/cni/${cni_version}/`. Acl is enabled, and telemetry is configured for prometheus.
Docker is installed as well, with volumes enabled. The infra image used by consul connect is configured as 
`registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0`.
There are also two host volumes mounted: `/mnt/cifs/nomad/` as `cifs` and `/opt/nomad/volume/` as `host`.

## Input

name | type | default |description
--- | --- | --- | ---
nomad_version | string | | the version of nomad
node_type | string | | will add an entry in meta of nomad client config
cni_version | string | "1.0.0" | 

## Output

output | type | description
--- | ---| ---
cloud_init_config | string | cloud init config content, should be merge with other cloud init configs
