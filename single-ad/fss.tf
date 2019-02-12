resource "oci_file_storage_mount_target" "fss_sap_mount_target" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  subnet_id           = "${oci_core_subnet.fss_private_subnets.id}"
  display_name        = "${var.fss_sap_mount_target_display_name}"
}

resource "oci_file_storage_file_system" "fss_sap_file_system" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.fss_sap_file_system_display_name}"
}

resource "oci_file_storage_file_system" "fss_sap_software_file_system" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.fss_sap_software_file_system_display_name}"
}

resource "oci_file_storage_file_system" "fss_sap_trans_file_system" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD -1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.fss_sap_trans_file_system_display_name}"
}

resource "oci_file_storage_export_set" "fss_sap_export_set" {
  mount_target_id   = "${oci_file_storage_mount_target.fss_sap_mount_target.id}"
  display_name      = "${var.fss_sap_export_set_name}"
  max_fs_stat_bytes = "${var.max_byte}"
  max_fs_stat_files = "${var.max_files}"
}

resource "oci_file_storage_export" "export_fss_sap_mnt" {
  export_set_id  = "${oci_file_storage_export_set.fss_sap_export_set.id}"
  file_system_id = "${oci_file_storage_file_system.fss_sap_file_system.id}"
  path           = "${var.export_path_fss_sap}"

  export_options = [
    {
      source                         = "${var.sap_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.database_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
  ]
}

resource "oci_file_storage_export" "export_fss_sap_software" {
  export_set_id  = "${oci_file_storage_export_set.fss_sap_export_set.id}"
  file_system_id = "${oci_file_storage_file_system.fss_sap_software_file_system.id}"
  path           = "${var.export_path_fss_sap_software}"

  export_options = [
    {
      source                         = "${var.sap_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.bastion_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.database_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.sap_route_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.sap_web_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
  ]
}

resource "oci_file_storage_export" "export_fss_sap_trans" {
  export_set_id  = "${oci_file_storage_export_set.fss_sap_export_set.id}"
  file_system_id = "${oci_file_storage_file_system.fss_sap_trans_file_system.id}"
  path           = "${var.export_path_fss_sap_trans}"

  export_options = [
    {
      source                         = "${var.sap_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.database_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
    {
      source                         = "${var.sap_web_subnet_cidr_block}"
      access                         = "READ_WRITE"
      identity_squash                = "NONE"
      require_privileged_source_port = true
    },
  ]
}
