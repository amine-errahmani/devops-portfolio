#!/bin/bash

echo '${admin_password}' | sudo -S yum-config-manager --disable epel | tee -a /tmp/st_reg.log
echo '${admin_password}' | sudo -S wget '${st_subscription_url}' | tee -a /tmp/st_reg.log
echo '${admin_password}' | sudo -S /usr/bin/python bootstrap.py -l sub_register -p '${st_sub_pass}' -s '${st_subscription_name}' --install-katello-agent --rex --rex-user='${admin_username}' --rex-urlkeyfile='${st_satellite_key_file}' -o '${st_bankname}' -L '${st_satellite_region}' -g '${st_satellite_environment}' -a '${st_rhel_version}' --skip=puppet --force --unmanaged" | tee -a /tmp/st_reg.log