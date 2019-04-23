## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 https://oss.oracle.com/licenses/upl/#_How_should_I

#!/bin/bash

# Preparing File System
sudo growpart /dev/sda 3

# Installing GUI and additional Packages for SAP Apps
sudo yum groupinstall 'Server with GUI' -y
sudo systemctl set-default graphical.target
sudo yum install uuidd libaio-devel ksh gcc -y
sudo yum install -y gcc-c++
sudo systemctl enable uuidd
sudo systemctl start uuidd

# Opening Firewall Ports for SAP Apps
sudo firewall-cmd --zone=public --permanent --add-port=3200-3299/tcp
sudo firewall-cmd --reload

# Installing SAP Metrics Colector agent
sudo wget https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/Ej8hZlFthynybW3Fi6UjcpKTJfVLMNwAP9wGyMH9GhU/n/imagegen/b/metrics-collector-binary-store/o/oci-sap-metrics-collector-1.0-8.noarch.rpm -P /tmp/
sudo yum install -y /tmp/oci-sap-metrics-collector-1.0-8.noarch.rpm

# Performing additional tunning options for SAP workloads
sudo bash -c 'echo kernel.sem=1250 256000 100 1024 >> /etc/sysctl.d/sap.conf'
sudo bash -c 'echo vm.max_map_count=2000000 >> /etc/sysctl.d/sap.conf'
sudo bash -c 'echo @sapsys soft nofile 32800 > /etc/security/limits.d/99-sap.conf'
sudo bash -c 'echo @sapsys hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'
sudo bash -c 'echo @oinstall soft nofile 32800 >> /etc/security/limits.d/99-sap.conf'
sudo bash -c 'echo @oinstall hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'

# Enabling growpart (autoresize)
sudo bash -c 'sed -i -e "s/#- growpart/ - growpart/g" /etc/cloud/cloud.cfg'

# Enabling/configuring ntp service
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

# Changing SELINUX to permissive mode
sudo bash -c 'sed -i -e "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/sysconfig/selinux'

# Creating LVM VGs/LVs for SAP
size=`sudo fdisk -l /dev/sdc | grep "GB" | cut -f 1 -d ',' | cut -f 3- -d '/' | grep sdc | awk '{ print $2 }' | cut -f 1 -d '.'`
value=105
if [ $size -lt $value ]
 	then
        echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/sdc
        sudo mkswap /dev/sdc1
        sudo chmod 777 /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/sdc1 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  swap swap defaults,_netdev,x-initrd.mount 0 0" >> /etc/fstab
        sudo chmod 600 /etc/fstab
        sudo swapoff -a
        sudo swapon -a
        echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/sdb
        sudo pvcreate /dev/sdb1
        sudo vgcreate vg_sap /dev/sdb1
        sudo lvcreate -L 30GB -n usr_sap vg_sap
        sudo lvcreate -L 5GB -n oracle_client vg_sap
        sudo mkfs.xfs /dev/vg_sap/usr_sap
        sudo mkfs.xfs /dev/vg_sap/oracle_client
        sudo mkdir -p /usr/sap
        sudo mount /dev/vg_sap/usr_sap /usr/sap
        sudo mkdir -p /usr/sap/trans
        sudo mkdir -p /oracle/client
        sudo mount /dev/vg_sap/oracle_client /oracle/client
        sudo chmod 777 /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/usr_sap | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /usr/sap xfs defaults,_netdev 0 2" >> /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/oracle_client | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/client xfs defaults,_netdev 0 2" >> /etc/fstab
        sudo chmod 600 /etc/fstab
else
	echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/sdb
	sudo mkswap /dev/sdb1
	sudo chmod 777 /etc/fstab
	sudo echo "UUID=`sudo blkid /dev/sdb1 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  swap swap defaults,_netdev,x-initrd.mount 0 0" >> /etc/fstab
	sudo chmod 600 /etc/fstab
	sudo swapoff -a
	sudo swapon -a
       echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/sdc
       sudo pvcreate /dev/sdc1
       sudo vgcreate vg_sap /dev/sdc1
       sudo lvcreate -L 30GB -n usr_sap vg_sap
       sudo lvcreate -L 5GB -n oracle_client vg_sap
       sudo mkfs.xfs /dev/vg_sap/usr_sap
       sudo mkfs.xfs /dev/vg_sap/oracle_client
       sudo mkdir -p /usr/sap
       sudo mount /dev/vg_sap/usr_sap /usr/sap
       sudo mkdir -p /usr/sap/trans
       sudo mkdir -p /oracle/client
       sudo mount /dev/vg_sap/oracle_client /oracle/client
       sudo chmod 777 /etc/fstab
       sudo echo "UUID=`sudo blkid /dev/vg_sap/usr_sap | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /usr/sap xfs defaults,_netdev 0 2" >> /etc/fstab
       sudo echo "UUID=`sudo blkid /dev/vg_sap/oracle_client | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/client xfs defaults,_netdev 0 2" >> /etc/fstab
       sudo chmod 600 /etc/fstab
 fi 
 
 # Enabling GUI
sudo bash -c 'init 3'
sleep 20
sudo bash -c 'init 5'
