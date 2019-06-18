## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 https://oss.oracle.com/licenses/upl/#_How_should_I

# Connect to Bastion Instance and mount FSS
resource "null_resource" "connect_to_bastion_instance" {
  connection {
    type        = "ssh"
    timeout     = "40m"
    host        = oci_core_instance.bastion_linux_instances.public_ip
    user        = "opc"
    private_key = chomp(file(var.ssh_private_key))
  }

  provisioner "file" {
    source      = "script-sap-bast.sh"
    destination = "/tmp/script-sap-bast.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nfs-utils > nfs-utils-install.log",
      "chmod +x /tmp/script-sap-bast.sh",
      "/tmp/script-sap-bast.sh",
      "sudo bash -c 'echo search ${var.vcn_dns_label}.oraclevcn.com ${var.database_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_web_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_route_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.bastion_subnet_label}.${var.vcn_dns_label}.oraclevcn.com > /etc/resolv.conf'",
      "sudo bash -c 'echo nameserver 169.254.169.254 >> /etc/resolv.conf'",
      "sudo bash -c 'chattr +i /etc/resolv.conf'",
    ]
  }
}

# Connect to SAP APP instance mount FSS and resize root partion
resource "null_resource" "connect_to_sap_app_instance" {
  depends_on = [
    oci_core_volume_attachment.sap_app_block_attach,
    oci_core_volume_attachment.sap_app_block_attach_swap,
    null_resource.connect_to_bastion_instance,
  ]

  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = oci_core_instance.sap_linux_instances.private_ip
    user                = "opc"
    private_key         = chomp(file(var.ssh_private_key))
    bastion_host        = oci_core_instance.bastion_linux_instances.public_ip
    bastion_user        = "opc"
    bastion_private_key = chomp(file(var.ssh_private_key))
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
      "sudo mkdir ${var.export_path_fss_sap_software}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo mkdir -p /usr/sap${var.export_path_fss_sap_trans}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_trans} /usr/sap${var.export_path_fss_sap_trans}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_trans} /usr/sap${var.export_path_fss_sap_trans} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo bash -c 'echo search ${var.vcn_dns_label}.oraclevcn.com ${var.database_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_web_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_route_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.bastion_subnet_label}.${var.vcn_dns_label}.oraclevcn.com > /etc/resolv.conf'",
      "sudo bash -c 'echo nameserver 169.254.169.254 >> /etc/resolv.conf'",
      "sudo bash -c 'chattr +i /etc/resolv.conf'",
    ]
  }
}

# Connect to SAP DB instance and resize root partion
resource "null_resource" "connect_to_sap_db_instance" {
  depends_on = [
    oci_core_volume_attachment.sap_db_block_attach_swap,
    null_resource.connect_to_sap_app_instance,
    null_resource.connect_to_bastion_instance,
  ]

  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = oci_core_instance.db_linux_instances.private_ip
    user                = "opc"
    private_key         = chomp(file(var.ssh_private_key))
    bastion_host        = oci_core_instance.bastion_linux_instances.public_ip
    bastion_user        = "opc"
    bastion_private_key = chomp(file(var.ssh_private_key))
  }

  provisioner "local-exec" {
    command = "sleep 15"
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
      "sudo mkdir ${var.export_path_fss_sap_software}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo mkdir -p /usr/sap${var.export_path_fss_sap_trans}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_trans} /usr/sap${var.export_path_fss_sap_trans}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_trans} /usr/sap${var.export_path_fss_sap_trans} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo bash -c 'echo search ${var.vcn_dns_label}.oraclevcn.com ${var.database_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_web_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_route_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.bastion_subnet_label}.${var.vcn_dns_label}.oraclevcn.com > /etc/resolv.conf'",
      "sudo bash -c 'echo nameserver 169.254.169.254 >> /etc/resolv.conf'",
      "sudo bash -c 'chattr +i /etc/resolv.conf'",
    ]
  }
}

# Connect to SAP Web Dispatcher
resource "null_resource" "connect_to_sap_web_dispatcher" {
  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = oci_core_instance.sap_web_dis_instances.private_ip
    user                = "opc"
    private_key         = chomp(file(var.ssh_private_key))
    bastion_host        = oci_core_instance.bastion_linux_instances.public_ip
    bastion_user        = "opc"
    bastion_private_key = chomp(file(var.ssh_private_key))
  }

  provisioner "file" {
    source      = "script-sap-disp.sh"
    destination = "/tmp/script-sap-disp.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script-sap-disp.sh",
      "/tmp/script-sap-disp.sh",
      "sudo mkdir ${var.export_path_fss_sap_software}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo mkdir ${var.export_path_fss_sap}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap} ${var.export_path_fss_sap} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo mkdir -p /usr/sap${var.export_path_fss_sap_trans}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_trans} /usr/sap${var.export_path_fss_sap_trans}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_trans} /usr/sap${var.export_path_fss_sap_trans} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo bash -c 'echo search ${var.vcn_dns_label}.oraclevcn.com ${var.database_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_web_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_route_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.bastion_subnet_label}.${var.vcn_dns_label}.oraclevcn.com > /etc/resolv.conf'",
      "sudo bash -c 'echo nameserver 169.254.169.254 >> /etc/resolv.conf'",
      "sudo bash -c 'chattr +i /etc/resolv.conf'",
    ]
  }
}

# Connect to SAP Router
resource "null_resource" "connect_to_sap_router" {
  connection {
    type                = "ssh"
    timeout             = "40m"
    host                = oci_core_instance.sap_router_instances.private_ip
    user                = "opc"
    private_key         = chomp(file(var.ssh_private_key))
    bastion_host        = oci_core_instance.bastion_linux_instances.public_ip
    bastion_user        = "opc"
    bastion_private_key = chomp(file(var.ssh_private_key))
  }

  provisioner "file" {
    source      = "script-sap-router.sh"
    destination = "/tmp/script-sap-router.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script-sap-router.sh",
      "/tmp/script-sap-router.sh",
      "sudo mkdir ${var.export_path_fss_sap_software}",
      "sudo mount ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software}",
      "echo ${local.sap_fss_mount_target_ip_address}:${var.export_path_fss_sap_software} ${var.export_path_fss_sap_software} nfs tcp,vers=3 | sudo tee -a /etc/fstab",
      "sudo bash -c 'echo search ${var.vcn_dns_label}.oraclevcn.com ${var.database_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_web_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.sap_route_subnet_label}.${var.vcn_dns_label}.oraclevcn.com ${var.bastion_subnet_label}.${var.vcn_dns_label}.oraclevcn.com > /etc/resolv.conf'",
      "sudo bash -c 'echo nameserver 169.254.169.254 >> /etc/resolv.conf'",
      "sudo bash -c 'chattr +i /etc/resolv.conf'",
    ]
  }
}

