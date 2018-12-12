# Bastion Linux Instances

resource "oci_core_instance" "bastion_linux_instances" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.bastion_linux_display_name}"
  shape               = "${var.bastion_linux_instance_shape}"
  hostname_label      = "${var.bastion_linux_hostname}"
  subnet_id           = "${oci_core_subnet.bastion_public_subnets.id}"

  source_details {
    source_type             = "image"
    source_id               = "${data.oci_core_images.InstanceImageOCID.images.0.id}"
    boot_volume_size_in_gbs = "${var.bastion_linux_boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }
}

# Bastion Windows Instances

resource "oci_core_instance" "bastion_windows_instances" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.bastion_windows_display_name}"
  shape               = "${var.bastion_windows_instance_shape}"
  hostname_label      = "${var.bastion_windows_hostname}"
  subnet_id           = "${oci_core_subnet.bastion_public_subnets.id}"

  source_details {
    source_type             = "image"
    source_id               = "${data.oci_core_images.WinInstanceImageOCID.images.0.id}"
    boot_volume_size_in_gbs = "${var.bastion_windows_boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }
}

# SAP Windows Application Instance

resource "oci_core_instance" "sap_windows_instances" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_windows_display_name}"
  shape               = "${var.sap_windows_instance_shape}"
  hostname_label      = "${var.sap_windows_hostname}"
  subnet_id           = "${oci_core_subnet.sap_private_subnets.id}"

  source_details {
    source_type             = "image"
    source_id               = "${data.oci_core_images.WinInstanceImageOCID.images.0.id}"
    boot_volume_size_in_gbs = "${var.sap_windows_boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }
}

# SAP Linux Application Instance

resource "oci_core_instance" "sap_linux_instances" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_linux_display_name}"
  shape               = "${var.sap_linux_instance_shape}"
  hostname_label      = "${var.sap_linux_hostname}"
  subnet_id           = "${oci_core_subnet.sap_private_subnets.id}"

  source_details {
    source_type             = "image"
    source_id               = "${data.oci_core_images.InstanceImageOCID.images.0.id}"
    boot_volume_size_in_gbs = "${var.sap_linux_boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  connection {
    type                = "ssh"
    timeout             = "15m"
    host                = "${self.private_ip}"
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
    ]
  }
}
