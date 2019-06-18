## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Block Volume for SAP Linux App Tier
resource "oci_core_volume" "sap_app_block" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.sap_app_block_display_name
  size_in_gbs         = var.sap_app_bv_size
}

resource "oci_core_volume_attachment" "sap_app_block_attach" {
  attachment_type = "paravirtualized"
  compartment_id  = var.compartment_ocid
  instance_id     = oci_core_instance.sap_linux_instances.id
  volume_id       = oci_core_volume.sap_app_block.id
}

# Extra SWAP Volume for SAP Linux App Tier
resource "oci_core_volume" "sap_app_block_swap" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.sap_app_block_swap_display_name
  size_in_gbs         = var.sap_app_swap_bv_size
}

resource "oci_core_volume_attachment" "sap_app_block_attach_swap" {
  attachment_type = "paravirtualized"
  compartment_id  = var.compartment_ocid
  instance_id     = oci_core_instance.sap_linux_instances.id
  volume_id       = oci_core_volume.sap_app_block_swap.id
}

# Extra SWAP Volume for DB Linux
resource "oci_core_volume" "sap_db_block_swap" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.sap_db_block_swap_display_name
  size_in_gbs         = var.sap_swap_db_bv_size
}

resource "oci_core_volume_attachment" "sap_db_block_attach_swap" {
  attachment_type = "iscsi"
  compartment_id  = var.compartment_ocid
  instance_id     = oci_core_instance.db_linux_instances.id
  volume_id       = oci_core_volume.sap_db_block_swap.id

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

  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
  }
}

