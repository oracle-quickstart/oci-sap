## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 https://oss.oracle.com/licenses/upl/#_How_should_I

locals {
  tcp_protocol       = "6"
  udp_protocol       = "17"
  all_protocols      = "all"
  anywhere           = "0.0.0.0/0"
  db_port            = "1521"
  ssh_port           = "22"
  winrm_port         = "5986"
  fss_ports          = ["2048", "2050", "111"]
  sap_dispatcher_min = "3200"
  sap_dispatcher_max = "3299"
  http_port          = "44300"
  https_port         = "443"
  vnc_port_min       = "5900"
  vnc_port_max       = "5902"
}

# Linux Bastion Security List
resource "oci_core_security_list" "BastionSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "BastionSecList"
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }

    protocol = local.tcp_protocol
    source   = local.anywhere
  }
  ingress_security_rules {
    tcp_options {
      min = local.vnc_port_min
      max = local.vnc_port_max
    }

    protocol = local.tcp_protocol
    source   = local.anywhere
  }
}

# Database System Security List
resource "oci_core_security_list" "DBSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "DBSecList"
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.db_port
      max = local.db_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.sap_dispatcher_min
      max = local.sap_dispatcher_max
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
}

# SAP Application Server Security List
resource "oci_core_security_list" "SAP_AppSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "SAPSecList"
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.sap_dispatcher_min
      max = local.sap_dispatcher_max
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
}

# SAP Web Dispatcher Security List
resource "oci_core_security_list" "SAP_WebSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "SAP_WebSecList"
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.http_port
      max = local.http_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.https_port
      max = local.https_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
}

# SAP Router Security List
resource "oci_core_security_list" "SAP_RouterSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "SAP_RouterSecList"
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.sap_dispatcher_min
      max = local.sap_dispatcher_max
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
}

# FSS Security List
resource "oci_core_security_list" "FSS_AppSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "FSSSecList"
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.anywhere
  }

  ingress_security_rules {
    tcp_options {
      min = local.fss_ports[0]
      max = local.fss_ports[1]
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    tcp_options {
      min = local.fss_ports[2]
      max = local.fss_ports[2]
    }

    protocol = local.tcp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    udp_options {
      min = local.fss_ports[0]
      max = local.fss_ports[0]
    }

    protocol = local.udp_protocol
    source   = var.vcn_cidr
  }
  ingress_security_rules {
    udp_options {
      min = local.fss_ports[2]
      max = local.fss_ports[2]
    }

    protocol = local.udp_protocol
    source   = var.vcn_cidr
  }
}

# Load Balancer Security List
resource "oci_core_security_list" "LB_SecList" {
  display_name   = "LB_SecList"
  compartment_id = oci_core_virtual_network.vcn.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 44300
      max = 44300
    }
  }
}

