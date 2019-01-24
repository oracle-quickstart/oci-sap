# Connect to Bastion Instance and mount FSS
resource "null_resource" "connect_to_bastion_instance" {
  connection {
    type        = "ssh"
    timeout     = "40m"
    host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    user        = "opc"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "sudo mkdir ${var.export_path_fss_sap}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo yum groupinstall 'Server with GUI' -y",
      "sudo systemctl set-default graphical.target",
      "sudo yum install tigervnc-server -y",
      "sudo firewall-cmd --zone=public --permanent --add-port=5900-5902/tcp",
      "sudo firewall-cmd --reload",
    ]
  }
}

# Connect to SAP APP instance mount FSS and resize root partion
resource "null_resource" "connect_to_sap_app_instance" {
  depends_on = ["oci_core_volume_attachment.sap_app_block_attach", "oci_core_volume_attachment.sap_app_block_attach_swap"]

  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = "${oci_core_instance.sap_linux_instances.private_ip}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }

  provisioner "file" {
    source      = "script-sap-app.sh"
    destination = "/tmp/script-sap-app.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script-sap-app.sh",
      "/tmp/script-sap-app.sh",
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "sudo mkdir ${var.export_path_fss_sap}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo growpart /dev/sda 3",
      "sudo yum groupinstall 'Server with GUI' -y",
      "sudo systemctl set-default graphical.target",
      "sudo yum install uuid libaio-devel ksh gcc -y",
      "sudo firewall-cmd --zone=public --permanent --add-port=3200-3299/tcp",
      "sudo firewall-cmd --reload",
      "sudo bash -c 'echo kernel.sem=1250 256000 100 1024 >> /etc/sysctl.d/sap.conf'",
      "sudo bash -c 'echo vm.max_map_count=2000000 >> /etc/sysctl.d/sap.conf'",
      "sudo bash -c 'echo @sapsys soft nofile 32800 > /etc/security/limits.d/99-sap.conf'",
      "sudo bash -c 'echo @sapsys hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'",
      "sudo bash -c 'echo @oinstall soft nofile 32800 >> /etc/security/limits.d/99-sap.conf'",
      "sudo bash -c 'echo @oinstall hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'",
    ]
  }
}

# Connect to SAP DB instance and resize root partion
resource "null_resource" "connect_to_sap_db_instance" {
  depends_on = ["oci_core_volume_attachment.sap_db_block_attach_swap"]

  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = "${oci_core_instance.db_linux_instances.private_ip}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }

  provisioner "file" {
    source      = "script-sap-db.sh"
    destination = "/tmp/script-sap-db.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script-sap-db.sh",
      "/tmp/script-sap-db.sh",
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "sudo mkdir ${var.export_path_fss_sap}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo growpart /dev/sda 3",
      "sudo yum groupinstall 'Server with GUI' -y",
      "sudo systemctl set-default graphical.target",
      "sudo yum install uuid libaio-devel ksh gcc -y",
      "sudo yum install oracle-database-server-12cR2-preinstall -y",
      "sudo firewall-cmd --zone=public --permanent --add-port=1521/tcp",
      "sudo firewall-cmd --reload",
      "sudo bash -c 'echo kernel.sem=1250 256000 100 1024 >> /etc/sysctl.d/sap.conf'",
      "sudo bash -c 'echo vm.max_map_count=2000000 >> /etc/sysctl.d/sap.conf'",
      "sudo bash -c 'echo @sapsys soft nofile 32800 > /etc/security/limits.d/99-sap.conf'",
      "sudo bash -c 'echo @sapsys hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'",
      "sudo bash -c 'echo @oinstall soft nofile 32800 >> /etc/security/limits.d/99-sap.conf'",
      "sudo bash -c 'echo @oinstall hard nofile 32800 >> /etc/security/limits.d/99-sap.conf'",
    ]
  }
}

# Connect to SAP Web Dispatcher
resource "null_resource" "connect_to_sap_web_dispatcher" {
  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = "${oci_core_instance.sap_web_dis_instances.private_ip}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo firewall-cmd --zone=public --permanent --add-port=80/tcp",
      "sudo firewall-cmd --zone=public --permanent --add-port=443/tcp",
      "sudo firewall-cmd --reload",
    ]
  }
}

# Connect to SAP Router
resource "null_resource" "connect_to_sap_router" {
  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = "${oci_core_instance.sap_router_instances.private_ip}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo firewall-cmd --zone=public --permanent --add-port=3200-3299/tcp",
      "sudo firewall-cmd --reload",
    ]
  }
}
