# Block Volume for SAP Linux App Tier
resource "oci_core_volume" "sap_app_block" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_app_block_display_name}"
  size_in_gbs         = "${var.sap_app_bv_size}"
}

resource "oci_core_volume_attachment" "sap_app_block_attach" {
  attachment_type = "paravirtualized"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.sap_linux_instances.id}"
  volume_id       = "${oci_core_volume.sap_app_block.id}"
}

# Extra SWAP Volume for SAP Linux App Tier
resource "oci_core_volume" "sap_app_block_swap" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_app_block_swap_display_name}"
  size_in_gbs         = "${var.sap_app_swap_bv_size}"
}

resource "oci_core_volume_attachment" "sap_app_block_attach_swap" {
  attachment_type = "paravirtualized"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.sap_linux_instances.id}"
  volume_id       = "${oci_core_volume.sap_app_block_swap.id}"
}

# Block Volume for DB Linux
resource "oci_core_volume" "sap_db_block" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_db_block_display_name}"
  size_in_gbs         = "${var.sap_db_bv_size}"
}

resource "oci_core_volume_attachment" "sap_db_block_attach" {
  attachment_type = "paravirtualized"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.db_linux_instances.id}"
  volume_id       = "${oci_core_volume.sap_db_block.id}"
}

# Extra SWAP Volume for DB Linux
resource "oci_core_volume" "sap_db_block_swap" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.sap_db_block_swap_display_name}"
  size_in_gbs         = "${var.sap_swap_db_bv_size}"
}

resource "oci_core_volume_attachment" "sap_db_block_attach_swap" {
  attachment_type = "paravirtualized"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.db_linux_instances.id}"
  volume_id       = "${oci_core_volume.sap_db_block_swap.id}"
}
