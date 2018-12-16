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
    ]
  }
}

# Connect to SAP DB instance and resize root partion
resource "null_resource" "connect_to_sap_db_instance" {
  depends_on = ["oci_core_volume_attachment.sap_db_block_attach", "oci_core_volume_attachment.sap_db_block_attach_swap"]

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
    ]
  }
}
