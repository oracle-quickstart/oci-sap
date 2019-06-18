## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Bastion Linux Instances

resource "oci_core_instance" "bastion_linux_instances" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.bastion_linux_display_name
  shape               = var.bastion_linux_instance_shape
  hostname_label      = var.bastion_linux_hostname
  subnet_id           = oci_core_subnet.bastion_public_subnets.id

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = var.bastion_linux_boot_volume_size
  }

  metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# SAP Router Instances

resource "oci_core_instance" "sap_router_instances" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.sap_router_display_name
  shape               = var.sap_router_instance_shape
  hostname_label      = var.sap_router_hostname
  subnet_id           = oci_core_subnet.sap_route_private_subnets.id

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = var.sap_router_boot_volume_size
  }

  metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# SAP Web Dispatcher Instance

resource "oci_core_instance" "sap_web_dis_instances" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.sap_web_dis_display_name
  shape               = var.sap_web_dis_instance_shape
  hostname_label      = var.sap_web_dis_hostname
  subnet_id           = oci_core_subnet.sap_web_public_subnets.id

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = var.sap_web_dis_boot_volume_size
  }

  metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

# SAP Linux Application Instance

resource "oci_core_instance" "sap_linux_instances" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.sap_linux_display_name
  shape               = var.sap_linux_instance_shape
  hostname_label      = var.sap_linux_hostname
  subnet_id           = oci_core_subnet.sap_private_subnets.id

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = var.sap_linux_boot_volume_size
  }

  metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

# DB Linux Application Instance

resource "oci_core_instance" "db_linux_instances" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = var.db_linux_display_name
  shape               = var.db_linux_instance_shape
  hostname_label      = var.db_linux_hostname
  subnet_id           = oci_core_subnet.db_private_subnets.id

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = var.db_linux_boot_volume_size
  }

  metadata = {
    ssh_authorized_keys = chomp(file(var.ssh_public_key))
  }
}

