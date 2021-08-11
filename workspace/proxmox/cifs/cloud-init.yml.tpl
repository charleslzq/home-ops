
packages:
  - cifs-utils
mounts:
 - [ "${cifs_path}", /mnt/cifs, cifs, "_netdev,nofail,username=${cifs_username},password=${cifs_password}", "0", "0" ]
 