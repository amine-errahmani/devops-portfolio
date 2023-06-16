#!/bin/sh
echo "----Configuring Repos"


OS="rhel"
VERSION="7"

sudo subscription-manager register \
          --username="${rhel_user}" \
          --password="${rhel_pass}" \
          --autosubscribe
          
sudo subscription-manager attach --pool "${rhel_pool}"

sudo rm -f /etc/yum/vars/releasever 
sudo yum --disablerepo='*' remove 'rhui-azure-rhel7-eus' -y 
sudo yum --config='https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel7.config' install -y 'rhui-azure-rhel7'

sudo yum-config-manager --add-repo=https://packages.microsoft.com/config/${OS}/${VERSION}/insiders-fast.repo

env

sudo curl -v https://packages.microsoft.com/keys/microsoft.asc > microsoft.asc
sudo rpm --import microsoft.asc

sudo yum update -y