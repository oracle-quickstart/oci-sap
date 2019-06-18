## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

/* Load Balancer */

resource "oci_load_balancer" "load_balancer" {
  shape          = var.lb_shape
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.lb_subnet.id,
  ]

  display_name = var.lb_display_name
}

resource "oci_load_balancer_backend_set" "lb_backend_set" {
  name             = var.lb_backend_set_name
  load_balancer_id = oci_load_balancer.load_balancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "44300"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/sap/wdisp/admin/public/default.html"
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_load_balancer_listener" "lb_listener" {
  load_balancer_id         = oci_load_balancer.load_balancer.id
  name                     = var.lb_backend_listener_name
  default_backend_set_name = oci_load_balancer_backend_set.lb_backend_set.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "2"
  }

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "oci_load_balancer_backend" "lb_backend" {
  load_balancer_id = oci_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.lb_backend_set.name
  ip_address       = oci_core_instance.sap_web_dis_instances.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1

  provisioner "local-exec" {
    command = "sleep 5"
  }
}

