## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 https://oss.oracle.com/licenses/upl/#_How_should_I

# Virtual Cloud Network (VCN)
resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  dns_label      = var.vcn_dns_label
  display_name   = var.vcn_name_label
}

# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vcn_dns_label}igw"
  vcn_id         = oci_core_virtual_network.vcn.id
}

# NAT (Network Address Translation) Gateway
resource "oci_core_nat_gateway" "natgtw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vcn_dns_label}natgtw"
}

# Service Gateway
resource "oci_core_service_gateway" "svcgtw" {
  compartment_id = var.compartment_ocid

  services {
    service_id = data.oci_core_services.svcgtw_services.services[0]["id"]
  }

  vcn_id       = oci_core_virtual_network.vcn.id
  display_name = "${var.vcn_dns_label}svcgtw"
}

# Public Route Table
resource "oci_core_route_table" "PublicRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vcn_dns_label}_pubrt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Private Route Table SAP application
resource "oci_core_route_table" "SAP_PrivateRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vcn_dns_label}_pvrt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.natgtw.id
  }
}

# Private Route Table Database
resource "oci_core_route_table" "DB_PrivateRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vcn_dns_label}_db_pvrt"

  route_rules {
    destination       = data.oci_core_services.svcgtw_services.services[0]["cidr_block"]
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.svcgtw.id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.natgtw.id
  }
}

# Private Route Table FSS
resource "oci_core_route_table" "FSS_PrivateRT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.vcn_dns_label}_fss_pvrt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Bastion Host Public Subnet
resource "oci_core_subnet" "bastion_public_subnets" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  cidr_block        = var.bastion_subnet_cidr_block
  display_name      = var.bastion_subnet_label
  dns_label         = var.bastion_subnet_label
  route_table_id    = oci_core_route_table.PublicRT.id
  security_list_ids = [oci_core_security_list.BastionSecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# SAP Web Dispatcher Public Subnet
resource "oci_core_subnet" "sap_web_public_subnets" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  cidr_block        = var.sap_web_subnet_cidr_block
  display_name      = var.sap_web_subnet_label
  dns_label         = var.sap_web_subnet_label
  route_table_id    = oci_core_route_table.PublicRT.id
  security_list_ids = [oci_core_security_list.SAP_WebSecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# SAP Router Private Subnet
resource "oci_core_subnet" "sap_route_private_subnets" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = var.sap_route_subnet_cidr_block
  display_name               = var.sap_route_subnet_label
  dns_label                  = var.sap_route_subnet_label
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.SAP_PrivateRT.id
  security_list_ids          = [oci_core_security_list.SAP_RouterSecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# SAP Application Private Subnet
resource "oci_core_subnet" "sap_private_subnets" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = var.sap_subnet_cidr_block
  display_name               = var.sap_subnet_label
  dns_label                  = var.sap_subnet_label
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.SAP_PrivateRT.id
  security_list_ids          = [oci_core_security_list.SAP_AppSecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# Database Private Subnet
resource "oci_core_subnet" "db_private_subnets" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = var.database_subnet_cidr_block
  display_name               = var.database_subnet_label
  dns_label                  = var.database_subnet_label
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.DB_PrivateRT.id
  security_list_ids          = [oci_core_security_list.DBSecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# FSS Private Subnet
resource "oci_core_subnet" "fss_private_subnets" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = var.fss_subnet_cidr_block
  display_name               = var.fss_subnet_label
  dns_label                  = var.fss_subnet_label
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.FSS_PrivateRT.id
  security_list_ids          = [oci_core_security_list.FSS_AppSecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# Load Balancer Subnets
resource "oci_core_subnet" "lb_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  cidr_block        = var.lb_subnet_cidr_block
  display_name      = var.lb_subnet_label
  dns_label         = var.lb_subnet_label
  route_table_id    = oci_core_route_table.PublicRT.id
  security_list_ids = [oci_core_security_list.LB_SecList.id]

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

