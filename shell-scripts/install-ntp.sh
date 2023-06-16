#!/bin/bash

#To stop chronyd
sudo systemctl stop chronyd

#To disable chronyd to run at bootup
sudo systemctl disable chronyd

#Install ntp on the server
sudo yum install ntp -y

#The config files for ntp lies in /etc/ntp.conf.
#We are changing the Servers time to our own ntp servers.

sudo sed -i "s/server 0.rhel.pool.ntp.org iburst/server IP iburst/g" /etc/ntp.conf
sudo sed -i "s/server 1.rhel.pool.ntp.org iburst/server IP iburst/g" /etc/ntp.conf
sudo sed -i "s/server 2.rhel.pool.ntp.org iburst//g" /etc/ntp.conf
sudo sed -i "s/server 3.rhel.pool.ntp.org iburst//g" /etc/ntp.conf

#Enable ntp the service.
sudo systemctl enable ntpd

#Restart the service.
sudo service ntpd restart