# Connect to Bastion Instance and mount FSS
resource "null_resource" "connect_to_bastion_instance" {
  connection {
    type        = "ssh"
    timeout     = "15m"
    host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    user        = "opc"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "sudo mkdir -p /mnt${var.export_path_fss_sap}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} /mnt${var.export_path_fss_sap}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} /mnt${var.export_path_fss_sap} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
    ]
  }
}

# Connect to SAP APP instance mount FSS and resize root partion
resource "null_resource" "connect_to_sap_app_instance" {
  connection {
    type                = "ssh"
    timeout             = "15m"
    host                = "${oci_core_instance.sap_linux_instances.private_ip}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "sudo mkdir -p /mnt${var.export_path_fss_sap}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} /mnt${var.export_path_fss_sap}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} /mnt${var.export_path_fss_sap} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo growpart /dev/sda 3",
    ]
  }
}

# Connect to SAP DB instance and resize root partion
resource "null_resource" "connect_to_sap_db_instance" {
  connection {
    type                = "ssh"
    timeout             = "15m"
    host                = "${oci_core_instance.db_linux_instances.private_ip}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${oci_core_instance.bastion_linux_instances.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo growpart /dev/sda 3",
    ]
  }
}
