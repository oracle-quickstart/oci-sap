# Get list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Get latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = "${var.tenancy_ocid}"
  operating_system         = "${var.instance_os}"
  operating_system_version = "${var.linux_os_version}"

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# Get Windows image
data "oci_core_images" "WinInstanceImageOCID" {
  compartment_id           = "${var.tenancy_ocid}"
  operating_system         = "${var.WinInstanceOS}"
  operating_system_version = "${var.WinInstanceOSVersion}"
}

# Get swift object storage name for Service Gateway
data "oci_core_services" "svcgtw_services" {
  filter {
    name   = "name"
    values = [".*Object.*Storage"]
    regex  = true
  }
}

## Get FSS Private IP
data "oci_core_private_ips" ip_sap_fss_mount_target {
  subnet_id = "${oci_file_storage_mount_target.fss_sap_mount_target.subnet_id}"

  filter {
    name   = "id"
    values = ["${oci_file_storage_mount_target.fss_sap_mount_target.private_ip_ids.0}"]
  }
}
