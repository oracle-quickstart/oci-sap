## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0

#!/bin/bash

# Installing GUI - X Packages
sudo yum groupinstall 'Server with GUI' -y
sudo systemctl set-default graphical.target

# Installing/Configuring VNC service
sudo yum install tigervnc-server -y
sudo firewall-cmd --zone=public --permanent --add-port=5900-5902/tcp
sudo firewall-cmd --reload
sudo bash -c 'cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service'
sudo systemctl daemon-reload
sudo bash -c 'sed -i -e "s/<USER>/opc/g" /etc/systemd/system/vncserver@:1.service'
sudo systemctl start vncserver@:1.service
sudo systemctl enable vncserver@:1.service

# Enabling growpart (autoresize)
sudo bash -c 'sed -i -e "s/#- growpart/ - growpart/g" /etc/cloud/cloud.cfg'

# Configuring/enabling ntp service
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

# Setting up VNC password. Make sure you CHANGE IT!
sudo bash -c 'curl -L http://169.254.169.254/opc/v1/instance/displayName | vncpasswd -f >> /home/opc/.vnc/passwd'
sudo bash -c 'chown -R opc.opc /home/opc/.vnc/'
sudo bash -c 'chmod 600 /home/opc/.vnc/passwd'

# Enabling GUI
sudo bash -c 'init 3'
sleep 20
sudo bash -c 'init 5'
