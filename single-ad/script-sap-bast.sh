#!/bin/bash

sudo yum groupinstall 'Server with GUI' -y
sudo systemctl set-default graphical.target
sudo yum install tigervnc-server -y
sudo firewall-cmd --zone=public --permanent --add-port=5900-5902/tcp
sudo firewall-cmd --reload
sudo bash -c 'cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service'
sudo systemctl daemon-reload
sudo bash -c 'sed -i -e "s/<USER>/opc/g" /etc/systemd/system/vncserver@:1.service'
sudo systemctl start vncserver@:1.service
sudo systemctl enable vncserver@:1.service
sudo bash -c 'sed -i -e "s/#- growpart/ - growpart/g" /etc/cloud/cloud.cfg'
sudo yum -y install ntp
sudo firewall-cmd --zone=public --permanent --add-port=123/udp
sudo firewall-cmd --reload
sudo ntpdate 169.254.169.254
sudo bash -c 'sed -i -e "s/server/#server/g" /etc/ntp.conf'
sudo bash -c 'echo server 169.254.169.254 iburst >> /etc/ntp.conf'
sudo bash -c 'echo "VNC_PASSWORD_CHANGE_ME" | vncpasswd -f >> /home/opc/.vnc/passwd'
sudo bash -c 'chown -R opc.opc /home/opc/.vnc/'
sudo bash -c 'chmod 600 /home/opc/.vnc/passwd'
sudo systemctl start ntpd
sudo systemctl enable ntpd
sudo systemctl stop chronyd
sudo systemctl disable chronyd
sudo bash -c 'init 3'
sleep 20
sudo bash -c 'init 5'
