#!/bin/bash

size=`sudo fdisk -l /dev/sdc | grep "GB" | cut -f 1 -d ',' | cut -f 3- -d '/' | grep sdc | awk '{ print $2 }' | cut -f 1 -d '.'`
value=70
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
        sudo lvcreate -L 20GB -n usr_sap_trans vg_sap
        sudo lvcreate -L 5GB -n oracle_client vg_sap
        sudo mkfs.xfs /dev/vg_sap/usr_sap
        sudo mkfs.xfs /dev/vg_sap/usr_sap_trans
        sudo mkfs.xfs /dev/vg_sap/oracle_client
        sudo mkdir -p /usr/sap
        sudo mount /dev/vg_sap/usr_sap /usr/sap
        sudo mkdir -p /usr/sap/trans
        sudo mount /dev/vg_sap/usr_sap_trans /usr/sap/trans
        sudo mkdir -p /oracle/client
        sudo mount /dev/vg_sap/oracle_client /oracle/client
        sudo chmod 777 /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/usr_sap | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /usr/sap xfs defaults,_netdev 0 2" >> /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/usr_sap_trans | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /usr/sap/trans xfs defaults,_netdev 0 2" >> /etc/fstab
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
        sudo lvcreate -L 20GB -n usr_sap_trans vg_sap
        sudo lvcreate -L 5GB -n oracle_client vg_sap
        sudo mkfs.xfs /dev/vg_sap/usr_sap
        sudo mkfs.xfs /dev/vg_sap/usr_sap_trans
        sudo mkfs.xfs /dev/vg_sap/oracle_client
        sudo mkdir -p /usr/sap
        sudo mount /dev/vg_sap/usr_sap /usr/sap
        sudo mkdir -p /usr/sap/trans
        sudo mount /dev/vg_sap/usr_sap_trans /usr/sap/trans
        sudo mkdir -p /oracle/client
        sudo mount /dev/vg_sap/oracle_client /oracle/client
        sudo chmod 777 /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/usr_sap | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /usr/sap xfs defaults,_netdev 0 2" >> /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/usr_sap_trans | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /usr/sap/trans xfs defaults,_netdev 0 2" >> /etc/fstab
        sudo echo "UUID=`sudo blkid /dev/vg_sap/oracle_client | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/client xfs defaults,_netdev 0 2" >> /etc/fstab
        sudo chmod 600 /etc/fstab
 fi 
       