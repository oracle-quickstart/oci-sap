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

# SAP Client Windows Instances

resource "oci_core_instance" "sap_client_windows_instances" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_client_windows_display_name}"
  shape               = "${var.sap_client_windows_instance_shape}"
  hostname_label      = "${var.sap_client_windows_hostname}"
  subnet_id           = "${oci_core_subnet.bastion_public_subnets.id}"

  source_details {
    source_type             = "image"
    source_id               = "${data.oci_core_images.WinInstanceImageOCID.images.0.id}"
    boot_volume_size_in_gbs = "${var.sap_client_windows_boot_volume_size}"
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
}

# DB Linux Application Instance

resource "oci_core_instance" "db_linux_instances" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.db_linux_display_name}"
  shape               = "${var.db_linux_instance_shape}"
  hostname_label      = "${var.db_linux_hostname}"
  subnet_id           = "${oci_core_subnet.db_private_subnets.id}"

  source_details {
    source_type             = "image"
    source_id               = "${data.oci_core_images.InstanceImageOCID.images.0.id}"
    boot_volume_size_in_gbs = "${var.db_linux_boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }
}
