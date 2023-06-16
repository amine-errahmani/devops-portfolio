#!/bin/bash

# ++++++++++++++
# FOR Ubuntu
# ++++++++++++++
# sudo apt -y update && sudo apt-get -y update
# sudo apt -y install software-properties-common

# sudo apt-add-repository ppa:ansible/ansible
# sudo apt -y update
# sudo apt -y install ansible

# ++++++++++++++
# FOR Rhel
# ++++++++++++++


#Switch a RHEL VM back to non-EUS (remove a version lock)
# sudo rm -f /etc/yum/vars/releasever 
# sudo yum --disablerepo='*' remove 'rhui-azure-rhel7-eus' -y
# sudo yum --config='https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel7.config' install -y 'rhui-azure-rhel7'

# update and install Ansible
sudo yum update -y
sudo yum install -y python
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y ansible

# sudo yum check-update
# sudo yum install -y gcc libffi-devel python-devel openssl-devel epel-release
# sudo yum install -y python-pip python-wheel

# sudo pip install ansible

sudo yum clean all

ansible --version
