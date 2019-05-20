## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0

#!/bin/bash

# Opening ports 80 and 443 in the OS firewall
sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --reload

# Installing GUI and additional packages required by SAP
sudo yum groupinstall 'Server with GUI' -y
sudo systemctl set-default graphical.target
sudo yum install uuidd libaio-devel ksh gcc -y
sudo yum install -y gcc-c++
sudo systemctl enable uuidd
sudo systemctl start uuidd

# Installing/Configuring ntp service
sudo yum -y install ntp
sudo firewall-cmd --zone=public --permanent --add-port=123/udp
sudo firewall-cmd --reload
sudo ntpdate 169.254.169.254
sudo bash -c 'sed -i -e "s/server/#server/g" /etc/ntp.conf'
sudo bash -c 'echo server 169.254.169.254 iburst >> /etc/ntp.conf'
sudo systemctl start ntpd
sudo systemctl enable ntpd
sudo systemctl stop chronyd
sudo systemctl disable chronyd

# Enabling growpart (autoresize)
sudo bash -c 'sed -i -e "s/#- growpart/ - growpart/g" /etc/cloud/cloud.cfg'

# Creating additional mount points 
sudo mkdir -p /usr/sap/trans

# Enabling GUI 
sudo bash -c 'init 3'
sleep 20
sudo bash -c 'init 5'
