#!/bin/bash
sudo growpart /dev/sda 3
sudo yum groupinstall 'Server with GUI' -y
sudo systemctl set-default graphical.target
sudo yum install uuidd libaio-devel ksh gcc -y
sudo yum install -y gcc-c++
sudo systemctl enable uuidd
sudo systemctl start uuidd
sudo yum install oracle-database-server-12cR2-preinstall -y
sudo firewall-cmd --zone=public --permanent --add-port=1521/tcp
sudo firewall-cmd --reload
sudo wget https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/Ej8hZlFthynybW3Fi6UjcpKTJfVLMNwAP9wGyMH9GhU/n/imagegen/b/metrics-collector-binary-store/o/oci-sap-metrics-collector-1.0-8.noarch.rpm -P /tmp/
sudo yum install -y /tmp/oci-sap-metrics-collector-1.0-8.noarch.rpm
sudo bash -c 'echo kernel.sem=1250 256000 100 1024 >> /etc/sysctl.d/sap.conf'
sudo bash -c 'echo vm.max_map_count=2000000 >> /etc/sysctl.d/sap.conf'
sudo bash -c 'echo @sapsys soft nofile 32800 > /etc/security/limits.d/99-sap.conf'
sudo bash -c 'echo @sapsys hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'
sudo bash -c 'echo @oinstall soft nofile 32800 >> /etc/security/limits.d/99-sap.conf'
sudo bash -c 'echo @oinstall hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'
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
sudo bash -c 'sed -i -e "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/sysconfig/selinux'
echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk /dev/sdb
sudo mkswap /dev/sdb1
sudo chmod 777 /etc/fstab
sudo echo "UUID=`sudo blkid /dev/sdb1 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  swap swap defaults,_netdev,x-initrd.mount 0 0" >> /etc/fstab
sudo chmod 600 /etc/fstab
sudo swapoff -a
sudo swapon -a
sudo pvcreate /dev/nvme0n1 -y
sudo vgcreate vg_sap_orcl /dev/nvme0n1
sudo lvcreate -L 5GB -n lv_orclient vg_sap_orcl
sudo lvcreate -L 30GB -n lv_oracle vg_sap_orcl
sudo lvcreate -L 20GB -n lv_sapdata1 vg_sap_orcl
sudo lvcreate -L 20GB -n lv_sapdata2 vg_sap_orcl
sudo lvcreate -L 20GB -n lv_sapdata3 vg_sap_orcl
sudo lvcreate -L 20GB -n lv_sapdata4 vg_sap_orcl
sudo lvcreate -L 5GB -n lv_origlogA vg_sap_orcl
sudo lvcreate -L 5GB -n lv_origlogB vg_sap_orcl
sudo lvcreate -L 5GB -n lv_mirrorA vg_sap_orcl
sudo lvcreate -L 5GB -n lv_mirrorB vg_sap_orcl
sudo lvcreate -L 20GB -n lv_oraarch vg_sap_orcl
sudo mkfs.xfs /dev/vg_sap_orcl/lv_orclient
sudo mkfs.xfs /dev/vg_sap_orcl/lv_oracle
sudo mkfs.xfs /dev/vg_sap_orcl/lv_sapdata1
sudo mkfs.xfs /dev/vg_sap_orcl/lv_sapdata2
sudo mkfs.xfs /dev/vg_sap_orcl/lv_sapdata3
sudo mkfs.xfs /dev/vg_sap_orcl/lv_sapdata4
sudo mkfs.xfs /dev/vg_sap_orcl/lv_origlogA
sudo mkfs.xfs /dev/vg_sap_orcl/lv_origlogB
sudo mkfs.xfs /dev/vg_sap_orcl/lv_mirrorA
sudo mkfs.xfs /dev/vg_sap_orcl/lv_mirrorB
sudo mkfs.xfs /dev/vg_sap_orcl/lv_oraarch
sudo mkdir -p /oracle/client
sudo mount /dev/vg_sap_orcl/lv_orclient /oracle/client
sudo mkdir -p /oracle/SAPSID
sudo mount /dev/vg_sap_orcl/lv_oracle /oracle/SAPSID
sudo mkdir -p /oracle/SAPSID/sapdata{1,2,3,4}
sudo mount /dev/vg_sap_orcl/lv_sapdata1 /oracle/SAPSID/sapdata1
sudo mount /dev/vg_sap_orcl/lv_sapdata2 /oracle/SAPSID/sapdata2
sudo mount /dev/vg_sap_orcl/lv_sapdata3 /oracle/SAPSID/sapdata3
sudo mount /dev/vg_sap_orcl/lv_sapdata4 /oracle/SAPSID/sapdata4
sudo mkdir -p /oracle/SAPSID/origlog{A,B}
sudo mount /dev/vg_sap_orcl/lv_origlogA /oracle/SAPSID/origlogA
sudo mount /dev/vg_sap_orcl/lv_origlogB /oracle/SAPSID/origlogB
sudo mkdir -p /oracle/SAPSID/mirror{A,B}
sudo mount /dev/vg_sap_orcl/lv_mirrorA /oracle/SAPSID/mirrorA
sudo mount /dev/vg_sap_orcl/lv_mirrorB /oracle/SAPSID/mirrorB
sudo mkdir -p /oracle/SAPSID/oraarch
sudo mount /dev/vg_sap_orcl/lv_oraarch /oracle/SAPSID/oraarch
sudo chmod 777 /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_orclient | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/client xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_oracle | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_sapdata1 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/sapdata1 xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_sapdata2 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/sapdata2 xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_sapdata3 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/sapdata3 xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_sapdata4 | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/sapdata4 xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_origlogA | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/origlogA xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_origlogB | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/origlogB xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_mirrorA | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/mirrorA xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_mirrorB | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/mirrorB xfs defaults,_netdev 0 2" >> /etc/fstab
sudo echo "UUID=`sudo blkid /dev/vg_sap_orcl/lv_oraarch | cut -d ':'  -f2 | cut -d '=' -f2 | cut -d '"' -f2`  /oracle/SAPSID/oraarch xfs defaults,_netdev 0 2" >> /etc/fstab
sudo chmod 600 /etc/fstab
sudo bash -c 'init 3'
sleep 20
sudo bash -c 'init 5'
