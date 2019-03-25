## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0

#!/bin/bash

# Opening ports 3200-3900 in the firewall
sudo firewall-cmd --zone=public --permanent --add-port=3200-3299/tcp
sudo firewall-cmd --reload

# Installing/Configuring NTP Service
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

