locals {
  tcp_protocol       = "6"
  udp_protocol       = "17"
  all_protocols      = "all"
  anywhere           = "0.0.0.0/0"
  db_port            = "1521"
  ssh_port           = "22"
  rdp_port           = "3389"
  winrm_port         = "5986"
  fss_ports          = ["2048", "2050", "111"]
  sap_dispatcher_min = "3200"
  sap_dispatcher_max = "3299"
}

# Linux and Windows Bastion Security List
resource "oci_core_security_list" "BastionSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "BastionSecList"
  vcn_id         = "${oci_core_virtual_network.vcn.id}"

  egress_security_rules = [
    {
      protocol    = "${local.tcp_protocol}"
      destination = "${local.anywhere}"
    },
  ]

  ingress_security_rules = [
    {
      tcp_options {
        "min" = "${local.ssh_port}"
        "max" = "${local.ssh_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"
    },
    {
      tcp_options {
        "min" = "${local.rdp_port}"
        "max" = "${local.rdp_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${local.anywhere}"
    },
  ]
}

# Database System Security List
resource "oci_core_security_list" "DBSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "DBSecList"
  vcn_id         = "${oci_core_virtual_network.vcn.id}"

  egress_security_rules = [
    {
      protocol    = "${local.tcp_protocol}"
      destination = "${local.anywhere}"
    },
  ]

  ingress_security_rules = [
    {
      tcp_options {
        "min" = "${local.ssh_port}"
        "max" = "${local.ssh_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      tcp_options {
        "min" = "${local.db_port}"
        "max" = "${local.db_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
  ]
}

# SAP Application Server Security List
resource "oci_core_security_list" "SAP_AppSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "SAPSecList"
  vcn_id         = "${oci_core_virtual_network.vcn.id}"

  egress_security_rules = [
    {
      protocol    = "${local.tcp_protocol}"
      destination = "${local.anywhere}"
    },
  ]

  ingress_security_rules = [
    {
      tcp_options {
        "min" = "${local.ssh_port}"
        "max" = "${local.ssh_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      tcp_options {
        "min" = "${local.rdp_port}"
        "max" = "${local.rdp_port}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      tcp_options {
        "min" = "${local.sap_dispatcher_min}"
        "max" = "${local.sap_dispatcher_max}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
  ]
}

# FSS Security List
resource "oci_core_security_list" "FSS_AppSecList" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "FSSSecList"
  vcn_id         = "${oci_core_virtual_network.vcn.id}"

  egress_security_rules = [
    {
      protocol    = "${local.tcp_protocol}"
      destination = "${local.anywhere}"
    },
  ]

  ingress_security_rules = [
    {
      tcp_options {
        "min" = "${local.fss_ports[0]}"
        "max" = "${local.fss_ports[1]}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      tcp_options {
        "min" = "${local.fss_ports[2]}"
        "max" = "${local.fss_ports[2]}"
      }

      protocol = "${local.tcp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      udp_options {
        "min" = "${local.fss_ports[0]}"
        "max" = "${local.fss_ports[0]}"
      }

      protocol = "${local.udp_protocol}"
      source   = "${var.vcn_cidr}"
    },
    {
      udp_options {
        "min" = "${local.fss_ports[2]}"
        "max" = "${local.fss_ports[2]}"
      }

      protocol = "${local.udp_protocol}"
      source   = "${var.vcn_cidr}"
    },
  ]
}
